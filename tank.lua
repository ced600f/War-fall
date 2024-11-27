require("timer")

local tankImage = love.graphics.newImage("images/base.png")
local turretImage = love.graphics.newImage("images/turret.png")
local imageWidth = tankImage:getWidth()
local imageHeight = tankImage:getHeight()
local offsetX = imageWidth / 2
local offsetY = imageHeight / 2
local tank = {}
local oldMouseButtonState = false
local barrelLength = 65
local angleCorrection = math.pi * 0.5
local turretImages = {}
turretImages[1] = love.graphics.newImage("images/turret.png")
turretImages[2] = love.graphics.newImage("images/turretHit.png")
turretImages[3] = love.graphics.newImage("images/turretFalling.png")

tank.x = SCREEN_WIDTH * 0.5 -- multiplication
tank.y = SCREEN_HEIGHT * 0.5
tank.tankImage = tankImage
tank.turretImage = turretImage
tank.angle = 0
tank.rotationSpeed = 2
tank.speed = 200
tank.radius = 50
tank.distanceBack = 0
tank.angleBack = 0
tank.turretAngle = 0
tank.touched = false
tank.falling = false
tank.ratio = 1
tank.points = 0

tank.shootTick = function()
end

tank.fall = function(dt)
    tank.turretImage = turretImages[3]
    tank.ratio = tank.ratio - 0.4 * dt
    if tank.ratio <= 0 then
        tank.ratio = 0
        changeScene("GameOver")
    end
end

tank.shootTimer = newTimer(0.3, tank.shootTick)

tank.back = function(dt)
    -- Conserver cette formule-------------
    local vx = tank.speed * math.cos(tank.angleBack) * dt * 2
    local vy = tank.speed * math.sin(tank.angleBack) * dt * 2
    local dist = math.dist(tank.x, tank.y, vx, vy) * dt
    tank.x = tank.x + vx
    tank.y = tank.y + vy

    tank.turretImage = turretImages[2]
    if GetTile(tank.x, tank.y) == 0 or tank.x <= 0 or tank.x >= SCREEN_WIDTH or tank.y <= 0 or tank.y >= SCREEN_HEIGHT then
        tank.falling = true
        tank.touched = false
    else
        tank.distanceBack = tank.distanceBack - math.floor(dist)
        if tank.distanceBack <= 0 then
            tank.touched = false
        end
    end
end

tank.update = function(dt)
    if tank.touched == true then
        tank.back(dt)
        return
    end
    if tank.falling == true then
        tank.fall(dt)
        return
    end
    local mouseX, mouseY = love.mouse.getPosition()
    local angle = math.atan2(mouseY - tank.y, mouseX - tank.x)
    tank.turretAngle = angle
    tank.turretImage = turretImage
    tank.shootTimer.update(dt)
    if love.mouse.isDown(1) and oldMouseButtonState == false then
        tank.shoot(love.mouse.getPosition())
    end

    oldMouseButtonState = love.mouse.isDown(1)

    if love.keyboard.isDown("left") then
        tank.angle = tank.angle - tank.rotationSpeed * dt
    elseif love.keyboard.isDown("right") then
        tank.angle = tank.angle + tank.rotationSpeed * dt
    end

    if love.keyboard.isDown("up") then
        tank.x = tank.x + math.cos(tank.angle) * tank.speed * dt
        tank.y = tank.y + math.sin(tank.angle) * tank.speed * dt
    elseif love.keyboard.isDown("down") then
        tank.x = tank.x - math.cos(tank.angle) * tank.speed * dt
        tank.y = tank.y - math.sin(tank.angle) * tank.speed * dt
    end

    if GetTile(tank.x, tank.y) == 0 or tank.x <= 0 or tank.x >= SCREEN_WIDTH or tank.y <= 0 or tank.y >= SCREEN_HEIGHT then
        tank.falling = true
    end
end

tank.shoot = function(x, y)
    if tank.shootTimer.started == false then
        tank.shootTimer.start()
        local b = newBullet()
        local x = barrelLength * math.cos(tank.turretAngle)
        local y = barrelLength * math.sin(tank.turretAngle)
        b.damage = b.damage * 2
        b.fire(tank.x + x, tank.y + y, tank.turretAngle)
    end
end

tank.draw = function()
    love.graphics.draw(
        tank.tankImage,
        tank.x,
        tank.y,
        tank.angle + angleCorrection,
        tank.ratio,
        tank.ratio,
        offsetX,
        offsetY
    )
    love.graphics.draw(
        tank.turretImage,
        tank.x,
        tank.y,
        tank.turretAngle + angleCorrection,
        tank.ratio,
        tank.ratio,
        offsetX,
        offsetY
    )
    love.graphics.circle("line", tank.x, tank.y, tank.radius)
    love.graphics.print("Points : " .. tostring(tank.points), 10, 50)
    love.graphics.print("x/y : " .. tostring(tank.x) .. "/" .. tank.y, 10, 80)
end

return tank
