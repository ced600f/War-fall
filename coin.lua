local coins = {}
local coinsImages = {}
local margin = 180

for i = 1, 2 do
    coinsImages[i] = love.graphics.newImage("Images/Bonus/Coin" .. i .. ".png")
end

function createCoin()
    local object = {}

    object.x = math.random(margin, SCREEN_WIDTH - margin)
    object.y = math.random(margin, SCREEN_HEIGHT - margin)
    object.life = 10
    local rand = math.random(1, #coinsImages)
    object.image = coinsImages[rand]
    object.imageWidth = object.image:getWidth()
    object.imageHeight = object.image:getHeight()

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
        love.graphics.rectangle("line", object.offsetX, object.offsetY, object.imageWidth, object.imageHeight)
        love.graphics.print(tostring(object.value), object.x, object.y)
    end

    return object
end

function newCoin()
    local object = createCoin()
    while checkObjectCollision(object) do
        object = createCoin()
    end
    table.insert(coins, object)
end

function updateCoins(dt)
    for i = #coins, 1, -1 do
        if coins[i].value == 0 then
            table.remove(coins, i)
        end
    end
end

function drawCoins()
    for _, object in ipairs(coins) do
        object.draw()
    end
end

function initCoins()
    for i = #coins, 1, -1 do
        table.remove(coins, i)
    end
end
