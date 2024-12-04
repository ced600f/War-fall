local bonus = {}
local bonusImages = {}
local margin = 180

BONUS_X3 = 1
BONUS_POWER = 2
BONUS_SHIELD = 3
BONUS_MINE = 4

for i = 1, 3 do
    bonusImages[i] = love.graphics.newImage("Images/Bonus/Bonus" .. i .. ".png")
end

function createBonus()
    local object = {}

    object.x = math.random(margin, SCREEN_WIDTH - margin)
    object.y = math.random(margin, SCREEN_HEIGHT - margin)
    local rand = math.random(1, #bonusImages)
    object.image = bonusImages[rand]
    object.type = rand

    object.imageWidth = object.image:getWidth()
    object.imageHeight = object.image:getHeight()
    object.radius = object.imageHeight
    object.sound = love.audio.newSource("Sons/Bonus.wav", "static")

    object.value = 10
    object.offsetX = object.x - object.imageWidth / 2
    object.offsetY = object.y - object.imageHeight / 2
    object.offsetX2 = object.offsetX + object.imageWidth
    object.offsetY2 = object.offsetY + object.imageHeight

    if rand == 2 then
        object.value = 100
    end

    object.draw = function()
        love.graphics.draw(object.image, object.x, object.y, 0, 1, 1, object.imageWidth / 2, object.imageHeight / 2)
    end

    return object
end

function newBonus()
    local object = createBonus()
    while checkObjectCollision(object) do
        object = createBonus()
    end
    table.insert(bonus, object)
end

function drawBonus()
    for i = #bonus, 1, -1 do
        if bonus[i].type == 0 then
            table.remove(bonus, i)
        end
    end
    for _, object in ipairs(bonus) do
        object.draw()
    end
end

function initBonus()
    for i = #bonus, 1, -1 do
        table.remove(bonus, i)
    end
end

function checkBonusCollision(tank)
    for _, object in ipairs(bonus) do
        if isIntersecting(object.x, object.y, object.radius, tank.x, tank.y, tank.radius) then
            tank.addBonus(object.type)
            object.type = 0
            object.sound:play()
        end
    end
end
