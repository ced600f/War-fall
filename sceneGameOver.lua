require("sceneManager")
local sceneMenu = newScene("GameOver")
local Image = love.graphics.newImage("images/gameover.png")
local Game = require("game")
local tank = require("tank")

sceneMenu.load = function(data)
    local sound = love.audio.newSource("sons/gameover.wav", "static")
    Game.Music:stop()
    sound:stop()
    sound:play()
end

sceneMenu.update = function(dt)
end

sceneMenu.draw = function()
    love.graphics.draw(Image, 0, 0)
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", SCREEN_WIDTH / 2 - 100, SCREEN_HEIGHT - 110, 200, 100)
    love.graphics.setColor(1, 1, 1)
    local fontOld = love.graphics.getFont()
    love.graphics.setFont(love.graphics.newFont(60))
    local font = love.graphics.getFont()
    local Size = font.Size
    local textWidth = font:getWidth(tank.points)
    local textHeight = font:getHeight()

    love.graphics.print(
        tank.points,
        (SCREEN_WIDTH / 2 - 100) + 100 - (textWidth / 2),
        (SCREEN_HEIGHT - 110 + 50) - textHeight / 2
    )
    love.graphics.setFont(fontOld)
end

sceneMenu.mousepressed = function(x, y, button)
    changeScene("Menu", "")
end

sceneMenu.keypressed = function(key)
    if key == "space" then
        changeScene("Menu", "")
    end
end
