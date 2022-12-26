include("lib.jl")

function main_f(r::Robot)
    f = (side::HorizonSide) -> !isborder(r, Nord)
    shuttle!(f, r, Nord)
    move!(r, Nord)
end