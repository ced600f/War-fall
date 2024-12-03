love.window.setMode(1920, 1080, {resizable = true, vsync = false, msaa = 4, centered = true})
SCREEN_WIDTH, SCREEN_HEIGHT = love.graphics.getDimensions()
love.graphics.setFont(love.graphics.newFont(16))

require("sceneManager")
require("sceneGame")
require("sceneMenu")
require("sceneGameOver")
require("utils")
require("timer")

math.randomseed(os.time())

function love.load()
    love.window.setTitle("War Fall")
    local cursor = love.mouse.newCursor("images/cross.png", 0, 0)
    love.mouse.setCursor(cursor)
    changeScene("Menu")
end

function love.update(dt)
    updateCurrentScene(dt)
end

function love.draw()
    drawCurrentScene()
end

function love.keypressed(key)
    keypressed(key)
end

function love.mousepressed(x, y, button)
    mousepressed(x, y, button)
end
