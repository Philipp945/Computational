using GLMakie
GLMakie.activate!(; float = true, focus_on_show = true)

# Parameters
road_length = 1000
steps = 1000
v_max = 5
car_density = 0.1
dawdling_probability = 0.5

# create car structure
mutable struct Car
    position::Int
    speed::Int
end

function init_cars(road_length, car_density)
    road = zeros(road_length)
    for i in 1:road_length
        if rand() < car_density
            road[i] = 1
        end
    end
    positions = findall(x -> x == 1, road)
    return [Car(pos, 0) for pos in positions]
end

function distance_to_next(i, cars, road_length)
    next_i = i+1
    if i == length(cars)
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

# plot
history = run_simulation(road_length, steps)

fig = Figure()
ax = Axis(fig[1,1], xlabel = "Position", ylabel = "Time")
heatmap!(ax, history'; colormap = :grays)
fig