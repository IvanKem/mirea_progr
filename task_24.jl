function moving_recursion!(robot,side) 
    if (!isborder(robot,side))
         move!(robot, side)
         if (!isborder(robot,side))
            move!(robot,side)
         end
         moving_recursion!(robot, side)
         move!(robot, inverse(side))
    end
end

inverse(side::HorizonSide) = HorizonSide((Int(side) +2)%4) 