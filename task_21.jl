include("lib.jl")

function main_f(r::Robot, condition::HorizonSide)
    f = (side::HorizonSide) -> !isborder(r, condition)
    shuttle!(f, r, condition)
    move!(r, condition)
end