require("sceneManager")
local sceneMenu = newScene("GameOver")
local Image = love.graphics.newImage("images/gameover.png")

sceneMenu.load = function(data)
end

sceneMenu.update = function(dt)
end

sceneMenu.draw = function()
    love.graphics.draw(Image, 0, 0)
end

sceneMenu.mousepressed = function(x, y, button)
    changeScene("Menu", "")
end

sceneMenu.keypressed = function(key)
    if key == "space" then
        changeScene("Menu", "")
    end
end
