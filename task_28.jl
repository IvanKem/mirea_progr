
function a(n::Int)
    c = 1
    for i in 2:5
        c = a + b
        a = b
        b = c
    end
    return c
end

function b(n::Int)
    if n == 1 || n == 2
        return 1
    else
        return f(n-2) + f(n-1)
    end
end
