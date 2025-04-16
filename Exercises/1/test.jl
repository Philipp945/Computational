function run_nasch_simulation()
    # Parameters
    v_max = 5
    p = 0.2
    road_length = 100
    n_cars = 30
    steps = 50

    # Initial setup
    positions = sort(rand(1:road_length, n_cars))
    velocities = zeros(Int, n_cars)

    # Helper function
    function distance_to_next(i, positions)
        next_i = i % length(positions) + 1
        return mod(positions[next_i] - positions[i] - 1, road_length)
    end

    # Main loop
    for step in 1:steps
        # 1. Acceleration
        for i in 1:n_cars
            velocities[i] = min(velocities[i] + 1, v_max)
        end

        # 2. Slowing down
        for i in 1:n_cars
            d = distance_to_next(i, positions)
            velocities[i] = min(velocities[i], d)
        end

        # 3. Random slowdown
        for i in 1:n_cars
            if velocities[i] > 0 && rand() < p
                velocities[i] -= 1
            end
        end

        # 4. Movement
        for i in 1:n_cars
            positions[i] = mod(positions[i] + velocities[i] - 1, road_length) + 1
        end

        # Sort positions to maintain order
        positions = sort(positions)

        # Print road state
        println("Step $step:")
        road = fill('.', road_length)
        for pos in positions
            road[pos] = 'C'
        end
        println(join(road))
    end
end

run_nasch_simulation()