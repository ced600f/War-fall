local bullets = {}
BULLET_NORMAL = 0
BULLET_X2 = 1

function newBullet()
    local b = {}

    b.x = 0
    b.y = 0
    b.angle = 0
    b.vx = 0
    b.vy = 0
    b.speed = 500
    b.damage = 200
    b.radius = 5
    b.free = false
    b.type = 0

    b.fire = function(x, y, angle)
        b.x = x
        b.y = y
        b.vx = math.cos(angle) * b.speed
        b.vy = math.sin(angle) * b.speed
    end

    b.update = function(dt)
        checkIntersection(b)

        if b.free == false then
            checkRebound(b)
            b.x = b.x + b.vx * dt
            b.y = b.y + b.vy * dt

            if b.x <= 0 or b.x >= SCREEN_WIDTH or b.y <= 0 or b.y >= SCREEN_WIDTH then
                b.free = true
            end
        end
    end

    b.draw = function()
        if b.type == BULLET_X2 then
            love.graphics.setColor(1, 0, 0, 1)
        end
        love.graphics.circle("fill", b.x, b.y, b.radius)
        love.graphics.setColor(1, 1, 1, 1)
    end

    table.insert(bullets, b)
    return b
end

function updateBullets(dt)
    for _, b in ipairs(bullets) do
        b.update(dt)
    end

    for i = #bullets, 1, -1 do
        local bullet = bullets[i]
        if bullet.free == true then
            table.remove(bullets, i)
        end
    end
end

function drawBullets(dt)
    for _, b in ipairs(bullets) do
        b.draw()
    end
end
