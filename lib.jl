using HorizonSideRobots
function next_side(side::HorizonSide)::HorizonSide #next_side
    return HorizonSide( (Int(side) + 1 ) % 4 )
end

function inverse(side::HorizonSide)::HorizonSide #inverse_side
    inv_side = HorizonSide((Int(side) + 2) % 4)
    return inv_side
end

function along!(robot, side, max_num) #along!
    n_steps = 0
    while !isborder(r, side) && n_steps < max_num
        move!(robot, side)
        n_steps += 1
    end
    return n_steps
end

function along_condition!(stop_condition, robot, side, max_num)
    n_steps = 0
    while !stop_condition(side) && n_steps < max_num
        move!(robot, side)
        n_steps += 1
    end
    return n_steps
end

function moves!(r::Robot, side::HorizonSide, n_steps::Int) # moves!
    for i in 1:n_steps
        move!(r, side)
    end
end

function move_and_put!(r::Robot, side::HorizonSide)::Int # putmarkers_until_border!
    n_steps = 0
    while !isborder(r, side) 
        move!(r, side)
        putmarker!(r)
        n_steps += 1
    end 
    return n_steps
end

function along_border!(r::Robot, side::HorizonSide)::Int # move_until_border!
    n_steps = 0
    while !isborder(r, side)
        n_steps += 1
        move!(r, side)
    end
    return n_steps
end


function make_perimetr!(r::Robot)#задача 2 #mark_perimetr!
    steps_to_left_down_angle = [0, 0] # (шаги_вниз, шаги_влево)
    steps_to_left_down_angle[1] = move_and_put!(r, Sud)
    steps_to_left_down_angle[2] = move_and_put!(r, West)
    for side in (Nord, Ost, Sud, West)
        move_and_put!(r, side)
    end
    moves!(r, Ost, steps_to_left_down_angle[2])
    moves!(r, Nord, steps_to_left_down_angle[1])
end

function left_corner!(r::Robot)::NTuple{2, Int}# перемещает робота в нижний левый угол, возвращает количество шагов # get_left_down_angle!
    steps_to_left_border = along_border!(r, West)
    steps_to_down_border = along_border!(r, Sud)
    return (steps_to_down_border, steps_to_left_border)
end

function left_corner_extended!(r::Robot)::Vector{Tuple{HorizonSide, Int}} #get_left_down_angle_modified!
    steps = []
    while !(isborder(r, West) && isborder(r, Sud))
        steps_to_West = along_border!(r, West)
        steps_to_Sud = along_border!(r, Sud)
        push!(steps, (West, steps_to_West))
        push!(steps, (Sud, steps_to_Sud))
    end
    return steps
end


function go_steps!(r::Robot, path::Vector{Tuple{HorizonSide, Int}}) # make_way!
    for step in path
        moves!(r, step[1], step[2])
    end
end

function inversed_path(path::Vector{Tuple{HorizonSide, Int}})::Vector{Tuple{HorizonSide, Int}}
    inv_path = []
    for step in path
        inv_step = (inverse(step[1]), step[2])
        push!(inv_path, inv_step)
    end
    reverse!(inv_path)
    return inv_path
end

function go_steps_inv!(r::Robot, path::Vector{Tuple{HorizonSide, Int}}) # make_way_back!
    inv_path = inversed_path(path)
    go_steps!(r, inv_path)
end

function go_startpos!(r::Robot, steps_to_origin::NTuple{2, Int}) # get_to_origin!
    for (i, side) in enumerate((Nord, Ost))
        moves!(r, side, steps_to_origin[i])
    end
end

function move_if_not_marker!(r::Robot, side::HorizonSide)::Bool #move_if_not_marker!
    
    if !ismarker(r)
        move!(r, side)
        return false
    end

    return true
end

function moves_if_not_marker!(r::Robot, side::HorizonSide, n_steps::Int)::Bool # moves_if_not_marker!

    for _ in 1:n_steps
        if move_if_not_marker!(r, side)
            return true
        end
    end
    
    return false
end

function move_if_possible!(r::Robot, side::HorizonSide)::Bool # move_if_possible!
    if !isborder(r, side)
        move!(r, side)
        return true
    end
    return false
end

function spiral!(stop_condition::Function, robot)
    n_steps = 1
    side = Ost
    while !stop_condition(side)
        along_condition!(stop_condition, robot, side, n_steps)
        side = next_side(side)
        along_condition!(stop_condition, robot, side, n_steps)
        side = next_side(side)
        n_steps +=1
    end
end

function shuttle!(stop_condition::Function, robot::Robot, side::HorizonSide)
    steps = 1
    direction = next_side(side)
    while !stop_condition(side)
        moves!(r, direction, steps)
        steps += 1
        direction = inverse(direction)
    end
end