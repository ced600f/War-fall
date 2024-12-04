require("sceneManager")
local sceneMenu = newScene("Menu")
local Image = love.graphics.newImage("images/intro.png")

sceneMenu.load = function(data)
end

sceneMenu.update = function(dt)
end

sceneMenu.draw = function()
    love.graphics.draw(Image, 0, 0)
end

sceneMenu.mousepressed = function(x, y, button)
    changeScene("Game", "")
end

sceneMenu.keypressed = function(key)
    if key == "space" then
        changeScene("Game", "")
    end
end

sceneMenu.gamepadpressed = function(joystick, button)
    changeScene("Game", "")
end
