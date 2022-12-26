using HorizonSideRobots

r=Robot(animate=true, "untitled.sit")
function mark_kross!(r::Robot) # - главная функция  
    num_vert = moves!(r, Sud)
    num_hor = moves!(r, West)
    for side in (Nord, Ost, Sud, West) # - перебор всех возможных направлений
        
        putmarkers!(r,side)
        
    end
    moves!(r, Nord, num_vert)
    moves!(r, Ost, num_hor)
    
end

# Всюду в заданном направлении ставит маркеры вплоть до перегородки, но в исходной клетке маркер не ставит
putmarkers!(r::Robot,side::HorizonSide) = 
    while isborder(r,side)==false 
        move!(r,side)
        putmarker!(r)
    end

function moves!(r::Robot, side::HorizonSide)
        num_steps=0
        while isborder(r,side)==false
            move!(r,side)
            num_steps+=1
        end
        return num_steps
    end

function moves!(r::Robot,side::HorizonSide, num_steps::Int)
        for _ in 1:num_steps # символ "_" заменяет фактически не используемую переменную
            move!(r,side)
        end
    end
mark_kross!(r)