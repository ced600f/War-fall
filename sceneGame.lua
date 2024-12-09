require("enemy")
require("bullet")
require("sceneManager")

local tank = require("tank")
local sceneGame = newScene("Game")
local myGame = require("game")

sceneGame.load = function(data)
    myGame.load()
end

sceneGame.unload = function()
    myGame.unload()
end

sceneGame.update = function(dt)
    myGame.update(dt)
end

sceneGame.draw = function()
    myGame.draw()
    tank.draw()
    drawEnemies()
    drawBullets()
end
