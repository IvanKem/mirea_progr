using HorizonSideRobots

include("lib-1.jl")
r=Robot(animate=true,"untitled.sit")
function cross!(robot)
    for side in (Nord, Sud, Ost, West)
        count = 0
        while !isborder(r, side) && !isborder(r, HorizonSide(mod(Int(side)+3, 4)))
            putmarker!(robot)
            move!(robot, side)
            move!(robot, HorizonSide(mod(Int(side)+3, 4)))
            putmarker!(robot)
            count +=1
        end
        for i in 1:count
            move!(robot, inverse(side))
            move!(robot, inverse(HorizonSide(mod(Int(side)+3, 4))))
        end
    end
end
cross!(r)