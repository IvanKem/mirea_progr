mutable struct Coordinates
    x::Int
    y::Int
end

using HorizonSideRobots

function HorizonSideRobots.move!(coords::Coordinates,side::HorizonSide)
    if side==Nord
        coord.y += 1
    elseif side==Sud
        coord.y -= 1
    elseif side==Ost
        coord.x += 1
    else #if side==West
        coord.x -= 1
    end
end

get_coords(coords::Coordinates) = (coord.x, coord.y)

HSR = HorizonSideRobots
struct CoordRobot
    robot::Robot
    coords::Coordinates
end
