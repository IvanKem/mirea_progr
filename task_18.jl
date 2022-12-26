include("lib.jl")
function along_condition18!(stop_condition, robot, side, n)
    i = 0
    while !stop_condition(side) && i < n
        cnt = 0
        if isborder(robot, side)
            while isborder(robot, side)
               move!(robot, next_side(side))
              cnt += 1
            end
            move!(robot, side)
            along!(robot, inverse(next_side(side)), cnt)
            i+=1
        else
            move!(robot, side)
            i += 1
        end
    end
    return i
end

function spiral18!(stop_condition::Function, robot)
    n = 1
    side = Ost
    while !stop_condition(side)
        along_condition18!(stop_condition, robot, side, n)
        side = next_side(side)
        along_condition18!(stop_condition, robot, side, n_)
        side = next_side(side)
        n += 1
    end
end

function main_f(r::Robot)
    f = (side::HorizonSide) -> ismarker(r)
    spiral18!( f, r)
end