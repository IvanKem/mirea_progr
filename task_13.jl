include("lib.jl")

function snake!(robot, (move_side, next_row_side)::NTuple{2,HorizonSide}=(Ost,Nord))
    steps = left_corner!(robot)
    to_mark = (steps[1] + steps[2]) % 2 == 0
    while !isborder(robot, move_side)
        while !isborder(robot, next_row_side)
            if to_mark
                putmarker!(robot)
            end
            move!(robot, next_row_side)
            to_mark = !to_mark
        end
        if to_mark
            putmarker!(robot)
        end
        move!(robot, move_side)
        to_mark = !to_mark
        if to_mark
            putmarker!(robot)
        end
        next_row_side = inverse(next_row_side)
    end

    while !isborder(robot, next_row_side)
        if to_mark
            putmarker!(robot)
        end
        move!(robot, next_row_side)
        to_mark = !to_mark
    end
    left_corner!(robot)
    go_startpos!(robot, steps)
end

function main_f(robot::Robot)
    snake!(robot, (Ost, Nord))
end    