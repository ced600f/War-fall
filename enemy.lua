local enemies = {}
local tank = require("tank")
local ennemiRatio = 0.60
local Image
local Images = {}
local barrelLength = 55
local rotationSpeed = 2
Images[1] = love.graphics.newImage("images/ennemi-idle.png")
Images[2] = love.graphics.newImage("images/ennemi-patrol.png")
Images[3] = love.graphics.newImage("images/ennemi-touched.png")
Images[4] = love.graphics.newImage("images/ennemi-falling.png")
Images[5] = love.graphics.newImage("images/ennemi-angry.png")
Image = Images[1]

local offsetX = Image:getWidth() / 2
local offsetY = Image:getHeight() / 2

function newEnemy(x, y)
    local enemy = {}
    enemy.x = x or 0 -- si x = nil alors on met 0
    enemy.y = y or 0
    enemy.angle = 0
    enemy.angleCible = 0
    enemy.distance = 0
    enemy.image = Image
    enemy.imageWidth = enemy.image:getWidth()
    enemy.imageHeight = enemy.image:getHeight()
    enemy.rx = enemy.imageWidth * 0.5
    enemy.ry = enemy.imageHeight * 0.5
    enemy.angleAffichage = (math.pi * 0.5)
    enemy.alpha = 0
    enemy.shootTimer = 0
    enemy.vitesseTir = 250
    enemy.speed = 120
    enemy.rayonChase = 500
    enemy.radius = 40
    enemy.shootRate = 0.8
    enemy.angleBack = 0
    enemy.distanceBack = 0
    enemy.free = false
    enemy.ratio = ennemiRatio
    enemy.points = 20
    enemy.push = 150
    enemy.hurtSound = love.audio.newSource("Sons/EnemyHurt.wav", "static")
    enemy.FallingSound = love.audio.newSource("Sons/EnemyFalling.wav", "static")

    enemy.show = function(dt)
        if enemy.alpha < 1 then
            enemy.alpha = enemy.alpha + 0.5 * dt
        else
            enemy.etat = enemy.avance
            enemy.image = Images[2]
        end
    end

    enemy.init = function(dt)
        math.randomseed(os.time())
        enemy.distance = love.math.random(1, 4)
        enemy.etat = enemy.show
    end

    enemy.etat = enemy.init

    enemy.fall = function(dt)
        enemy.image = Images[4]
        enemy.ratio = enemy.ratio - 0.2 * dt
        if enemy.ratio <= 0 then
            enemy.ratio = 0
            enemy.free = true
        end
    end

    enemy.shoot = function(x, y)
        if enemy.shootTimer >= enemy.shootRate then
            enemy.shootTimer = 0
            local b = newBullet()
            local x = barrelLength * math.cos(enemy.angle)
            local y = barrelLength * math.sin(enemy.angle)

            b.fire(enemy.x + x, enemy.y + y, enemy.angle)
        end
    end

    enemy.hunt = function(dt)
        local angle = math.angle(enemy.x, enemy.y, tank.x, tank.y)
        enemy.angleCible = angle
        enemy.etat = enemy.avance
        --enemy.distance = 0.5
        enemy.image = Images[5]
        enemy.shoot(tank.x, tank.y)
        enemy.avance(dt)
    end

    enemy.changeDirection = function(dt)
        local angleAleatoire = math.random((math.pi) * -1, math.pi)
        enemy.angleCible = enemy.angleCible + angleAleatoire
        if enemy.angleCible < 0 then
            enemy.angleCible = enemy.angleCible + math.pi * 2
        elseif enemy.angleCible > math.pi * 2 then
            enemy.angleCible = enemy.angleCible - math.pi * 2
        end
        enemy.image = Images[2]
        enemy.etat = enemy.avance
        enemy.distance = love.math.random(20, 30) / 10
    end

    enemy.avance = function(dt)
        -- Conserver cette formule-------------
        local vx = enemy.speed * math.cos(enemy.angle) * dt
        local vy = enemy.speed * math.sin(enemy.angle) * dt
        ---------------------------------------

        enemy.x = enemy.x + vx
        enemy.y = enemy.y + vy
        enemy.distance = enemy.distance - dt
        local dist = math.dist(enemy.x, enemy.y, tank.x, tank.y)
        if dist <= enemy.rayonChase then
            enemy.etat = enemy.hunt
        elseif enemy.distance <= 0 then
            enemy.etat = enemy.changeDirection
        end

        -- Test si l'ennemi arrive en bout de carte, on change de direction
        if enemy.x < TILE_WIDTH / 2 then
            enemy.x = TILE_WIDTH / 2
            enemy.checkDistance()
        end
        if enemy.x > SCREEN_WIDTH - TILE_WIDTH / 2 then
            enemy.x = SCREEN_WIDTH - TILE_WIDTH / 2
            enemy.checkDistance()
        end
        if enemy.y < TILE_HEIGHT / 2 then
            enemy.y = TILE_HEIGHT / 2
            enemy.checkDistance()
        end
        if enemy.y > SCREEN_HEIGHT - TILE_HEIGHT / 2 then
            enemy.y = SCREEN_HEIGHT - TILE_HEIGHT / 2
            enemy.checkDistance()
        end
        -- L'ennemi s'est déplacé à l'extérieur de la carte, on ne le laisse pas tomber
        if GetTile(enemy.x, enemy.y) == 0 then
            enemy.x = enemy.x - vx
            enemy.y = enemy.y - vy
            enemy.checkDistance()
        end

        -- Test si on colisionne avec un objet
        if checkVehicleCollision(enemy) then
            enemy.x = enemy.x - vx
            enemy.y = enemy.y - vy
            enemy.checkDistance()
        end
    end

    -- On ne passe pas directement au changement de direction
    -- Cela faisait des effets non désirés (liés probablement au timer)
    -- On laisse l'ennemi "avancer" sur place 1/2 s avant changement de direction
    enemy.checkDistance = function()
        if enemy.distance > 0.5 then
            enemy.distance = 0.5
        end
    end

    enemy.back = function(dt)
        -- Conserver cette formule-------------
        rotationSpeed = 6
        local vx = enemy.speed * rotationSpeed * math.cos(enemy.angleBack) * dt
        local vy = enemy.speed * rotationSpeed * math.sin(enemy.angleBack) * dt
        local dist = math.dist(enemy.x, enemy.y, vx, vy) * dt
        enemy.x = enemy.x + vx
        enemy.y = enemy.y + vy
        enemy.angleCible = enemy.angleCible + math.random(-math.pi / 2, math.pi / 2)
        enemy.image = Images[3]

        if
            GetTile(enemy.x, enemy.y) == 0 or enemy.x <= 0 or enemy.x >= SCREEN_WIDTH or enemy.y <= 0 or
                enemy.y >= SCREEN_HEIGHT
         then
            enemy.etat = enemy.fall
            tank.points = tank.points + enemy.points
            enemy.FallingSound:play()
        elseif checkVehicleCollision(enemy) then
            enemy.x = enemy.x - vx
            enemy.y = enemy.y - vy
            enemy.etat = enemy.changeDirection
        else
            enemy.distanceBack = enemy.distanceBack - math.floor(dist)
            if enemy.distanceBack <= 0 then
                enemy.etat = enemy.changeDirection
                rotationSpeed = 2
            end
        end
    end

    enemy.update = function(dt)
        if enemy.angle < enemy.angleCible then
            enemy.angle = enemy.angle + rotationSpeed * dt
        elseif enemy.angle > enemy.angleCible then
            enemy.angle = enemy.angle - rotationSpeed * dt
        end
        enemy.shootTimer = enemy.shootTimer + dt
        enemy.etat(dt)
    end

    enemy.draw = function()
        love.graphics.setColor(1, 1, 1, enemy.alpha)
        love.graphics.draw(
            enemy.image,
            enemy.x,
            enemy.y,
            enemy.angle + enemy.angleAffichage,
            enemy.ratio,
            enemy.ratio,
            offsetX,
            offsetY
        )
        love.graphics.setColor(1, 1, 1, 1)
        --love.graphics.circle("line", enemy.x, enemy.y, enemy.radius)
    end

    table.insert(enemies, enemy)
    return enemy
end

function spawnEnemy()
    local x = 0
    local y = 0
    x = math.random(0, SCREEN_WIDTH)
    y = math.random(0, SCREEN_HEIGHT)
    while GetTile(x, y) ~= 5 do
        x = math.random(0, SCREEN_WIDTH)
        y = math.random(0, SCREEN_HEIGHT)
    end
    local e = newEnemy(x, y)
    e.angle = math.random(0, math.pi * 2)
    e.angleCible = e.angle
end

function updateEnemies(dt)
    for n = #enemies, 1, -1 do
        local e = enemies[n]
        e.update(dt)
        if e.free == true then
            table.remove(enemies, n)
        end
    end
end

function drawEnemies()
    love.graphics.print("NB enemies : " .. #enemies, 10, 150)
    for _, enemy in ipairs(enemies) do
        enemy.draw()
    end
end

function deleteAllEnemies()
    for i = #enemies, 1, -1 do
        table.remove(enemies, i)
    end
end

function checkIntersection(bullet)
    if isIntersecting(tank.x, tank.y, tank.radius, bullet.x, bullet.y, bullet.radius) then
        tank.touched = true
        local angle = math.angle(bullet.x, bullet.y, tank.x, tank.y)
        tank.angleBack = angle
        tank.distanceBack = bullet.damage
        bullet.free = true
        tank.hurtSound:stop()
        tank.hurtSound:play()
    else
        for i = 1, #enemies do
            local enemy = enemies[i]
            if enemy.etat ~= enemy.fall then
                if
                    enemy.alpha >= 1 and
                        isIntersecting(enemy.x, enemy.y, enemy.radius, bullet.x, bullet.y, bullet.radius)
                 then
                    local angle = math.angle(bullet.x, bullet.y, enemy.x, enemy.y)
                    enemy.angleBack = angle
                    enemy.distanceBack = bullet.damage
                    bullet.free = true
                    enemy.etat = enemy.back
                    enemy.hurtSound:play()
                elseif enemy.alpha >= 1 and isIntersecting(enemy.x, enemy.y, enemy.radius, tank.x, tank.y, tank.radius) then
                    local angle = math.angle(tank.x, tank.y, enemy.x, enemy.y)
                    enemy.angleBack = angle
                    enemy.distanceBack = tank.push
                    enemy.etat = enemy.back
                    enemy.hurtSound:play()

                    angle = angle + math.pi
                    tank.angleBack = angle
                    tank.distanceBack = enemy.push
                    tank.touched = true
                end
            end
        end
    end
end
