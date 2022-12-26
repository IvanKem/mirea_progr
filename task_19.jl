include("lib.jl")

function main_f(robot::Robot, side::HorizonSide, n_steps::Int = 0)
    if !isborder(r, side)
        move!(r, side)
        n_steps += 1
        main_f(r, side, n_steps)
    end
end