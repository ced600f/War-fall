require("timer")
local tankImage = love.graphics.newImage("images/base.png")
local turretImage = love.graphics.newImage("images/turret.png")
local imageWidth = tankImage:getWidth()
local imageHeight = tankImage:getHeight()
local offsetX = imageWidth / 2
local offsetY = imageHeight / 2
local tank = {}
local oldMouseButtonState = false
local BARREL_LENGTH = 65
local DEFAULT_DAMAGE = 600
local angleCorrection = math.pi * 0.5
local turretImages = {}
local BONUS_DURATION = 30
local joysticks = love.joystick.getJoysticks()
local gamepad = joysticks[1]

turretImages[1] = love.graphics.newImage("images/turret.png")
turretImages[2] = love.graphics.newImage("images/turretHit.png")
turretImages[3] = love.graphics.newImage("images/turretFalling.png")

tank.init = function()
    tank.x = SCREEN_WIDTH * 0.5 -- multiplication
    tank.y = SCREEN_HEIGHT * 0.5
    tank.image = tankImage
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
    tank.push = 800
    tank.bombs = 0
    tank.bonus = {}
    tank.shieldImage = love.graphics.newImage("images/shield.png")
    tank.shootTimer = newTimer(0.3, 0.3, tank.shootTick, false)
    tank.hurtSound = love.audio.newSource("Sons/TankHurt.wav", "static")
    tank.fallingSound = love.audio.newSource("Sons/TankFalling.wav", "static")
end

tank.shootTick = function()
end

tank.addBonus = function(bonus)
    local b = {}
    b.type = bonus
    b.duration = 0
    if bonus == BONUS_MINE then
        tank.bombs = tank.bombs + 1
    else
        table.insert(tank.bonus, b)
    end
end

tank.updateBonus = function(dt)
    for _, bonus in ipairs(tank.bonus) do
        bonus.duration = bonus.duration + dt
    end
    for i = #tank.bonus, 1, -1 do
        local bonus = tank.bonus[i]
        if bonus.duration >= BONUS_DURATION then
            table.remove(tank.bonus, i)
        end
    end
end

tank.fall = function(dt)
    tank.turretImage = turretImages[3]
    tank.ratio = tank.ratio - 0.4 * dt
    if tank.ratio <= 0 then
        tank.ratio = 0
        deleteAllEnemies()
        changeScene("GameOver")
    end
end

tank.isBonusPresent = function(b)
    local bRetour = false

    for _, bonus in ipairs(tank.bonus) do
        if bonus.type == b then
            bRetour = true
        end
    end

    return bRetour
end

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
        tank.fallingSound:stop()
        tank.fallingSound:play()
    else
        tank.distanceBack = tank.distanceBack - math.floor(dist)
        if tank.distanceBack <= 0 then
            tank.touched = false
        end
    end
end

tank.update = function(dt)
    tank.updateBonus(dt)

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
    if love.mouse.isDown(1) and oldMouseButtonState == false then
        tank.shoot()
    end

    oldMouseButtonState = love.mouse.isDown(1)

    if love.keyboard.isDown("left") then
        tank.angle = tank.angle - tank.rotationSpeed * dt
    elseif love.keyboard.isDown("right") then
        tank.angle = tank.angle + tank.rotationSpeed * dt
    end

    local x = tank.x
    local y = tank.y

    if love.keyboard.isDown("up") then
        tank.x = tank.x + math.cos(tank.angle) * tank.speed * dt
        tank.y = tank.y + math.sin(tank.angle) * tank.speed * dt
    elseif love.keyboard.isDown("down") then
        tank.x = tank.x - math.cos(tank.angle) * tank.speed * dt
        tank.y = tank.y - math.sin(tank.angle) * tank.speed * dt
    end

    -- Gestion du gamepad
    if gamepad then
        -- Turret
        local gx = gamepad:getGamepadAxis("rightx")
        local gy = gamepad:getGamepadAxis("righty")
        tank.turretAngle = math.atan2(gy, gx)

        -- Tank
        local leftx = gamepad:getGamepadAxis("leftx")
        local lefty = gamepad:getGamepadAxis("lefty")
        if leftx <= -0.5 then
            tank.angle = tank.angle - tank.rotationSpeed * dt
        elseif leftx >= 0.5 then
            tank.angle = tank.angle + tank.rotationSpeed * dt
        end

        if lefty <= -0.5 then
            tank.x = tank.x + math.cos(tank.angle) * tank.speed * dt
            tank.y = tank.y + math.sin(tank.angle) * tank.speed * dt
        elseif lefty >= 0.5 then
            tank.x = tank.x - math.cos(tank.angle) * tank.speed * dt
            tank.y = tank.y - math.sin(tank.angle) * tank.speed * dt
        end

        -- Gachette ?
        if gamepad:isGamepadDown("rightshoulder") or gamepad:getGamepadAxis("triggerright") >= 0.5 then
            tank.shoot()
        end
    end

    if checkVehicleCollision(tank) then
        tank.x = x
        tank.y = y
    end

    checkCoinCollision(tank)
    checkBonusCollision(tank)

    if GetTile(tank.x, tank.y) == 0 or tank.x <= 0 or tank.x >= SCREEN_WIDTH or tank.y <= 0 or tank.y >= SCREEN_HEIGHT then
        tank.falling = true
        tank.fallingSound:stop()
        tank.fallingSound:play()
    end
end

tank.createBullet = function(turretAngle, correction)
    local b = newBullet()
    local x = BARREL_LENGTH * math.cos(turretAngle)
    local y = BARREL_LENGTH * math.sin(turretAngle)
    b.damage = DEFAULT_DAMAGE

    if tank.isBonusPresent(BONUS_POWER) then
        b.damage = b.damage * 2
        b.type = BULLET_X2
    end
    b.fire(tank.x + x, tank.y + y, turretAngle + correction)
end

tank.shoot = function()
    if tank.shootTimer.started == false then
        tank.shootTimer.start()

        tank.createBullet(tank.turretAngle, 0)

        if tank.isBonusPresent(BONUS_X3) then
            -- math.pi/12 = 15°
            tank.createBullet(tank.turretAngle, -math.pi / 12)
            tank.createBullet(tank.turretAngle, math.pi / 12)
        end
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
    if tank.isBonusPresent(BONUS_SHIELD) then
        love.graphics.draw(
            tank.shieldImage,
            tank.x,
            tank.y,
            tank.angle + angleCorrection,
            tank.ratio,
            tank.ratio,
            offsetX,
            offsetY
        )
    end

    love.graphics.print("Points : " .. tostring(tank.points), 10, 10)
end

return tank
