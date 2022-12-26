using HorizonSideRobots
HSR=HorizonSideRobots

mutable struct Coordinates
    x::Int
    y::Int
  end
Coordinates() = Coordinates(0,0)
  # вправо с минусом в лево с плюсом
function HorizonSideRobots.move!(coord::Coordinates, side::HorizonSide)
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

get_coord(coord::Coordinates) = (coord.x , coord.y)
coord=Coordinates()


struct CoordRobot
    robot::Robot
    coord::Coordinates
    
end

r=Robot(animate=false, "untitled.sit")
CoordRobot(robot) = CoordRobot(robot, Coordinates()) 
robot=CoordRobot(r)

function HorizonSideRobots.move!(robot::CoordRobot, side)
    
    move!(robot.robot, side)
    move!(robot.coord, side)
    push!(passed_coordinates,get_coord(robot.coord))
    println(passed_coordinates)
end
get_coord(robot::CoordRobot) = get_coord(robot.coord)


HorizonSideRobots.isborder(robot::CoordRobot, side) = isborder(robot.robot, side)
HorizonSideRobots.putmarker!(robot::CoordRobot) = putmarker!(robot.robot)
HorizonSideRobots.ismarker(robot::CoordRobot) = ismarker(robot.robot)
HorizonSideRobots.temperature(robot::CoordRobot) = temperature(robot.robot)
  


inverse(side::HorizonSide)::HorizonSide = HorizonSide(mod(Int(side)+2, 4))

right(side::HorizonSide)::HorizonSide = HorizonSide(mod(Int(side)+1, 4))
left(side::HorizonSide)::HorizonSide = HorizonSide(mod(Int(side)-1, 4))


mutable struct DirectRobot{TypeRobot} 
        robot::TypeRobot
        direct::HorizonSide
end

DirectRobot{TypeRobot}(robot) where TypeRobot = DirectRobot{TypeRobot}(robot, Nord) 


HorizonSideRobots.move!(robot::DirectRobot) = move!(robot.robot, robot.direct)

DirectFunction = Union{typeof(left), typeof(right),typeof(inverse), typeof(something)} 

function turn!(robot::DirectRobot, direct::DirectFunction)::Nothing 
        robot.direct = direct(robot.direct)
        return nothing
end

HSR.isborder(robot::DirectRobot,direct::DirectFunction)=isborder(robot.robot,direct(robot.direct))

HSR.isborder(robot::DirectRobot) = isborder(robot,something) 
HSR.putmarker!(robot::DirectRobot) = putmarker!(robot.robot)
HSR.ismarker(robot::DirectRobot) = ismarker(robot.robot)
HSR.temperature(robot::DirectRobot)=temperature(robot.robot)

along!(direct_robot::DirectRobot) = while try_move!(direct_robot) end

function numsteps_along!(direct_robot::DirectRobot) 
    num_steps = 0
        while try_move!(direct_robot) 
            num_steps += 1
        end
    return num_steps
end

along!(stop_condition::Function, direct_robot::DirectRobot) = while !stop_condition() || try_move!(direct_robot) end

function numsteps_along!(stop_condition::Function, direct_robot::DirectRobot)
    num_steps = 0
    while !stop_condition() || try_move!(direct_robot) 
        num_steps += 1
    end
    return num_steps
end


try_move!(direct_robot::DirectRobot) = (forward!(direct_robot); true)

global @enum Оrientation Positive=0 Negaive=1
inverse(orientation::Оrientation) =  Оrientation(mod(Int(orientation)+1, 2))

mutable struct EdgeRobot{TypeRobot}
    robot::DirectRobot{TypeRobot}
    orientation::Оrientation

#move!(robot::EdgeRobot, direct::Оrientation)


    function EdgeRobot{TypeRobot}(robot::TypeRobot, orientation::Orientation=Positive) where TypeRobot
            # Робота надо развернуть в положительном направлении обхода границы (граница слева), так, чтобы он мог сделать шаг вперед 
            if orientation == Positive
                rot_fun = left
                inv_rot_fun = right
            else # orientation == Negative
                inv_rot_fun = left 
                rot_fun = right
            end
            direct_side = Nord
            direct_robot = DirectRobot{TypeRobot}(robot, direct_side)
            n=0
            while !isborder(direct_robot) && n < 4
                turn!(rot_fun, direct_robot)
                n += 1
            end
            if !isborder(direct_robot)
                throw("Рядом с роботом отсутствует перегородка")
            end
            n = 0
            while isborder(direct_robot) && n < 4
                turn!(inv_rot_fun, direct_robot)
                n += 1
            end
            if isborder(direct_robot)
                throw("Робот ограничен со всех 4-х сторон")
            end
            #УТВ: Слева от робота перегородка и он может сделать шаг вперед
            return new(direct_robot, orientation)
        end
end
        
function inverse!(robot::EdgeRobot)::Nothing
    if robot.orientation == Positive
                #=
        Дано: слева - перегородка (или её нет, если только робот - на углу),
        спереди - свободно
        Требуется: справа - перегородка (или её нет, если только робот - на
        углу), спереди - свободно
        =#
        turn!(left, robot.robot)
        while isborder(robot.robot) # если только робот - на углу,то цикл не выполняется ни разу
            turn!(left, robot.robot)
        end
    else # robot.orientation == Negative
        # аналогично ...
        turn!(right, robot.robot)
        while isborder(robot.robot)
            turn!(right, robot.robot)
        end
    end
    robot.orientation = inverse(robot.orientation)
    return nothing
end

function HorizonSideRobots.move!(robot::EdgeRobot)::Nothing
    function turns!(turn_direct::Function,  inv_turn_direct::Function)
    # Разворачивает робота так, чтобы слева/справа была граница, а     спереди - свободно
        if !isborder(turn_direct, robot.robot)
            turn!(turn_direct, robot.robot)
        else
            while isborder(robot.robot)
                turn!(inv_turn_direct, robot.robot)
            end
        end
        return nothing 
    end
     
    move!(robot.robot) 
    # - смещеает робота вперед на 1 клетку в направлении robot.robot.direct
    
    # Далее выполняется разворот:
    if robot.orientation == Positive
        turns!(left, right) 
        # УТВ: cлева - граница, спереди - свободно
    else # orientation == Negative 
        turns!(right, left) 
    # УТВ: cправа - граница, спереди - свободно
    end 
    return nothing
end

get_robot(robot::EdgeRobot)::Robot = get_robot(robot.robot)
get_direct(robot::EdgeRobot)::HorizonSide = get_direct(robot.robot)
get_orientation(robot::EdgeRobot)::Orientation = robot.orientation

HorizonSideRobots.putmarker!(robot::DirectRobot) = putmarker!(robot.robot)
HorizonSideRobots.ismarker(robot::DirectRobot) = ismarker(robot.robot)
HorizonSideRobots.temperature(robot::DirectRobot) = temperature(robot.robot)    

function move!(robot::EdgeRobot, direct::Orientation)
    (direct != get_orientation(robot)) && inverse!(robot)
    move!(robot)
end

mutable struct AroundRobot{TypeRobot}
    robot::EdgeRobot{TypeRobot} 
    
    start_coord::NTuple{2,Int}# - стартовые кординаты робота
    start_direct::HorizonSide # - стартовое направление робота 
       
    AroundRobot{TypeRobot}(robot::TypeRobot) where TypeRobot  = new(EdgeRobot{TypeRobot}(robot), get_coord(robot), get_direct(robot.robot))
end

get_coord(robot::AroundRobot)=get_coord(robot.robot)

get_direct(robot::AroundRobot)=get_direct(robot.robot)

is_start(robot::AroundRobot) = (get_coord(robot) == robot.start_coord ) && (get_direct(robot) == robot.start_direct)
HorizonSideRobots.move!(robot::AroundRobot) = move!(robot.robot)

function around!(robot::AroundRobot, direct::Orientation=Positive)
    move!(robot, direct)
    while !is_start(robot)
        move!(robot, direct) 
    end
end

struct PutmarcerCoordrobot <: SimpleRobot
        robot::Robot
        coord::Coords
    end
    
    get_robot(robot::PutmarcerCoordrobot) = robot.robot
    
    function HorizonSideRobots.move!(robot::PutmarcerCoordrobot, side)
        move!(robot, side)
        move!(robot.coord,side)
        putmarker!(robot)
    end

robot=PytmarkerCoordrobot(Robot("untitled.sit"), Coords(0, 0))
robot = AroundRobot{PytmarkerCoordrobot}(robot)
around!(robot)
    