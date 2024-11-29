local objects = {}
local objectsAvailables = {}
local margin = 180

for i = 1, 15 do
    objectsAvailables[i] = love.graphics.newImage("Images/Tiles/Object_" .. i .. ".png")
end

function createObject()
    local object = {}

    object.x = math.random(margin, SCREEN_WIDTH - margin)
    object.y = math.random(margin, SCREEN_HEIGHT - margin)
    object.life = 15
    local rand = math.random(1, #objectsAvailables)
    object.image = objectsAvailables[rand]
    object.imageWidth = object.image:getWidth()
    object.imageHeight = object.image:getHeight()

    object.rebound = false
    object.offsetX = object.x - object.imageWidth / 2
    object.offsetY = object.y - object.imageHeight / 2
    object.offsetX2 = object.offsetX + object.imageWidth
    object.offsetY2 = object.offsetY + object.imageHeight

    if rand == 3 or rand == 4 or rand == 7 then
        object.rebound = true
    end

    object.draw = function()
        love.graphics.draw(object.image, object.x, object.y, 0, 1, 1, object.imageWidth / 2, object.imageHeight / 2)
        love.graphics.rectangle("line", object.offsetX, object.offsetY, object.imageWidth, object.imageHeight)
        love.graphics.print(tostring(object.life), object.x, object.y)
    end

    return object
end

function initObjects()
    for i = #objects, 1, -1 do
        table.remove(objects, i)
    end

    for i = 1, 15 do
        local object = createObject()
        while checkObjectCollision(object) do
            object = createObject()
        end
        table.insert(objects, object)
    end
end

function updateObjects(dt)
    for i = #objects, 1, -1 do
        if objects[i].life == 0 then
            table.remove(objects, i)
        end
    end
end

function drawObjects()
    for _, object in ipairs(objects) do
        object.draw()
    end
end

function checkRebound(bullet)
    for i = 1, #objects do
        local object = objects[i]
        if object.rebound == true then
            -- si ma bullet touche un objet "rebondissant"
            if
                (bullet.x + bullet.radius >= object.offsetX and bullet.x - bullet.radius <= object.offsetX2) and
                    (bullet.y + bullet.radius >= object.offsetY and bullet.y - bullet.radius <= object.offsetY2)
             then
                -- On se base sur le radius de la balle et de sa position "interne" dans la boite pour déterminer la vélocité à appliquer
                local dx = math.abs(bullet.x - object.x)
                local dy = math.abs(bullet.y - object.y)
                -- les objets sont carrés on teste juste la distance en X ou Y
                if dx > dy then
                    bullet.vx = bullet.vx * -1
                elseif dx < dy then
                    bullet.vy = bullet.vy * -1
                else
                    bullet.vx = bullet.vx * -1
                    bullet.vy = bullet.vy * -1
                end

                object.life = object.life - 1
            end
        end
    end
end

function checkVehicleCollision(vehicle)
    local collision = false

    return collision
end

function checkObjectCollision(newObjectund)
    local collision = false

    for _, object in ipairs(objects) do
        if collide(object, newObject) then
            collision = true
        end
    end

    return collision
end
