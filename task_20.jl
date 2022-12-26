include("lib.jl")

function main_f(r::Robot, side::HorizonSide, steps)
    if !isborder(r, side)
        move!(r, side)
        steps += 1
        main_f(r, side, steps)
    else
        putmarker!(r)
        along!(r, inverse(side), steps)
    end
end

