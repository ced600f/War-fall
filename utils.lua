-- Retourne la distance entre deux points
function math.dist(x1, y1, x2, y2)
    return ((x2 - x1) ^ 2 + (y2 - y1) ^ 2) ^ 0.5
end

function isIntersecting(x1, y1, r1, x2, y2, r2)
    local dist = math.dist(x1, y1, x2, y2)
    local rSum = r1 + r2

    return dist < rSum
end

function collide(a1, a2)
    if (a1 == a2) then
        return false
    end
    local dx = a1.x - a2.x
    local dy = a1.y - a2.y

    if (math.abs(dx) < a1.image:getWidth() + a2.image:getWidth()) then
        if (math.abs(dy) < a1.image:getHeight() + a2.image:getHeight()) then
            return true
        end
    end

    return false
end

function math.angle(x1, y1, x2, y2)
    return math.atan2(y2 - y1, x2 - x1)
end
