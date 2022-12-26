include("lib.jl")

function find_marker!(r::Robot)
    f = (side::HorizonSide) -> ismarker(r)
    spiral!( f, r)
end

function main_f(r::Robot)
    find_marker!(r)
end