local objects = {}
local objectsAvailables = {}
local margin = 180

for i = 1, 15 do
    objectsAvailables[i] = love.graphics.newImage("Images/Tiles/Object_" .. i .. ".png")
end

math.randomseed(os.time())

for i = 1, 15 do
    local object = {}

    object.x = math.random(margin, SCREEN_WIDTH - margin)
    object.y = math.random(margin, SCREEN_HEIGHT - margin)

    local rand = math.random(1, #objectsAvailables)
    object.image = objectsAvailables[rand]

    object.draw = function()
        love.graphics.draw(
            object.image,
            object.x,
            object.y,
            0,
            1,
            1,
            object.image:getWidth() / 2,
            object.image:getHeight() / 2
        )
    end

    table.insert(objects, object)
end

function drawObjects()
    for _, object in ipairs(objects) do
        object.draw()
    end
end
