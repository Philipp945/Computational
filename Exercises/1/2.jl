using GLMakie
GLMakie.activate!(; float = true, focus_on_show = true)

# Parameters
road_length = 1000
steps = 1000
v_max = 5
car_density = 0.2
dawdling_probability = 0.15

mutable struct Car
    position::Int
    speed::Int
end

function init_cars(road_length, car_density)
    num_cars = Int(car_density * road_length)
    positions = sort(rand(1:road_length, num_cars))
    return [Car(pos, 0) for pos in positions]
end

function distance_to_next(i, cars, road_length)
    next_i = i+1
    if next_i == length(cars)+1 # circular track
        next_i = 1
        return cars[next_i].position - cars[i].position + road_length
    end
    return cars[next_i].position - cars[i].position
end

function update_cars!(cars, road_length)
    for i in eachindex(cars)
        d = distance_to_next(i, cars, road_length)
        # acceleration
        if cars[i].speed < v_max
            cars[i].speed += 1
        end
        # braking
        if d <= cars[i].speed
            cars[i].speed = d-1
        end
        # dawdling
        if rand() < dawdling_probability && cars[i].speed > 0
            cars[i].speed -= 1
        end
        cars[i].speed = min(cars[i].speed, v_max)
        
        # movement
        cars[i].position = mod1(cars[i].position + cars[i].speed, road_length)
        end
    sort!(cars, by = c -> c.position)
end

# === Run Simulation ===

function run_simulation(road_length, steps)
    cars = init_cars(road_length, car_density)
    history = zeros(Int8, steps, road_length)

    for t in 1:steps
        for car in cars
            history[t, car.position] = 1
        end
        update_cars!(cars, road_length)
    end
    return history
end

# === Plot ===

history = run_simulation(road_length, steps)

f = Figure()
ax = Axis(f[1,1], ylabel = "Position", xlabel = "Time")
heatmap!(ax, history'; colormap = :grays)
f