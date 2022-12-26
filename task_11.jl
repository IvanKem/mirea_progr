include("lib.jl")

function snake_horizontal!(robot::Robot, side::HorizonSide)
    side = Ost
    ans = 0
    tmp = 0
    while !isborder(robot, side)
        move!(robot, side)
        if tmp == 0 && isborder(robot, Nord)
            tmp = 1
        end
        if tmp == 1 && !isborder(robot, Nord)
            tmp = 0
            ans += 1
        end

        if (!isborder(robot, Nord) && isborder(robot, side))
            move!(robot, Nord)
        end

        if isborder(robot, Nord) && (isborder(robot, West) || isborder(robot, Ost))
            return ans
        end

        if isborder(robot, side)
            side = inverse(side)
        end
    end
    return ans
end
function main_f(robot::Robot)
    steps = left_corner!(robot)
    ans = snake_horizontal!(robot, Ost)
    left_corner!(robot)
    go_startpos!(robot, steps)
    print(ans)
end