using HorizonSideRobots
inverse(side::HorizonSide)=HorizonSide(mod(Int(side)+2,4))
right(side::HorizonSide)::HorizonSide = HorizonSide(mod(Int(side)+1, 4))
left(side::HorizonSide)::HorizonSide = HorizonSide(mod(Int(side)-1, 4))
walk_by(r::Robot,side::HorizonSide) = while isborder(r,Nord)==true move!(r,side) end
next(side::HorizonSide)=HorizonSide(mod(Int(side)+1,4))
moves!(r,side,num_steps)=for _ in 1:num_steps move!(r,side) end

function start_pos_define(robot)
    global x_pos = 0
    global y_pos = 0
    global z_pos = 0
    while !isborder(robot, Sud)
        x_pos += 1
        move!(robot, Sud)
    end
    while !isborder(robot, West)
        move!(robot, West)
        y_pos += 1
    end
    while !isborder(robot, Sud)
        move!(robot, Sud)
        z_pos += 1
    end
end

function goto_start_pos(robot)
    for i = 1:z_pos
        move!(robot, Nord)
    end
    for i = 1:y_pos
        move!(robot, Ost)
    end
    for i = 1:x_pos
        move!(robot, Nord)
    end
end

function along!(robot, side)
    while !isborder(robot, side)
        move!(robot, side)
    end
end

function along_markers!(robot, side)
    while !isborder(robot, side)
        putmarker!(robot)
        move!(robot, side)
        putmarker!(robot)
    end
end

function south_west(robot)
        along!(robot, West)
        along!(robot, Sud)
end

function marker_special!(r, x, y, cell_size)
    if (mod(x, 2 * cell_size)) < cell_size && (mod(y, 2 * cell_size)) < cell_size || 
        (mod(x + cell_size, 2 * cell_size)) < cell_size && (mod(y, 2 * cell_size)) >= cell_size
        putmarker!(r)
    end
end

function move_up_condition(r)
    return isborder(r, Ost) || isborder(r, West) && !(isborder(r, South) && isborder(r, West))
end


function go_to_west_south_corner_and_return_path!(r::Robot; go_around_barriers::Bool = false, markers = false)::Array{Tuple{HorizonSide,Int64},1}
    my_ans = []
    a = go_to_border_and_return_path!(r, West; go_around_barriers, markers)
    b = go_to_border_and_return_path!(r, Sud; go_around_barriers, markers)

    for i in a
        push!(my_ans, i)
    end
    for i in b
        push!(my_ans, i)
    end
    return my_ans
end

function go_by_path!(r::Robot, path::Array{Tuple{HorizonSide,Int64},1})
    new_path = reverse(path)
    for i in new_path
        go!(r, i[1]; steps = i[2])
    end
end

function go_to_border_and_return_path!(r::Robot, side::HorizonSide; go_around_barriers::Bool = false, markers = false)::Array{Tuple{HorizonSide,Int64},1}
my_ans = [ (Nord, 0) ]
if go_around_barriers
    steps = 0
    if markers
        putmarker!(r)
    end
    if !isborder(r, side)
        move!(r, side)
        steps = 1
        push!(my_ans, (inverse(side), 1) )
    else
        path = go_around_barrier_and_return_path!(r, side)
        steps = get_path_length_in_direction(path, side)
        for i in path
            push!(my_ans, i)
        end
    end
    if markers
        putmarker!(r)
    end
    while steps > 0
        if !isborder(r, side)
            move!(r, side)
            steps = 1
            push!(my_ans, (inverse(side), 1) )
            if markers
                putmarker!(r)
            end
        else
            path = go_around_barrier_and_return_path!(r, side)
            steps = get_path_length_in_direction(path, side)
            for i in path
                push!(my_ans, i)
            end
            if markers
                putmarker!(r)
            end
        end
    end

else
    steps=0
    steps_now = go!(r,side; markers)
    while steps_now > 0
        steps += steps_now
        steps_now = go!(r,side; markers)
    end
    push!(my_ans, (inverse(side), steps) )
end
return my_ans
end

function go!(r::Robot, side::HorizonSide; steps::Int = 1, go_around_barriers::Bool = false, markers = false)::Int
    my_ans = 0
    if markers
        putmarker!(r)
    end
    if (go_around_barriers)
        path = around_move_return_path!(r, side; steps, markers)
        my_ans = get_path_length_in_direction(path, side)
    else
        for i ∈ 1:steps

            if (markers)
                putmarker!(r)
            end

            if !isborder(r, side)
                move!(r, side)
                my_ans += 1
            else
                for i ∈ 1:my_ans
                    move!(r, inverse(side))
                end
                my_ans = 0
                break
            end
        end
        if (markers)
            putmarker!(r)
        end
    end

    return my_ans
end

function get_left_down_angle_modified!(r::Robot)::Vector{Tuple{HorizonSide, Int}}
    steps = []
    while !(isborder(r, West) && isborder(r, Sud))
        steps_to_West = move_until_border!(r, West)
        steps_to_Sud = move_until_border!(r, Sud)
        push!(steps, (West, steps_to_West))
        push!(steps, (Sud, steps_to_Sud))
    end
return steps
