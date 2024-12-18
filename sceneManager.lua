local scenes = {}

function newScene(title)
    local scene = {}

    scene.title = title

    scene.load = function(data)
    end

    scene.update = function(dt)
    end

    scene.draw = function()
    end

    scene.unload = function()
    end

    scene.keypressed = function(key)
    end

    scene.mousepressed = function(x, y, button)
    end

    scene.gamepadpressed = function(joystick, button)
    end

    scenes[title] = scene

    return scene
end

local currentScene = nil

function changeScene(title, data)
    if currentScene then -- equivalent ~= nil
        currentScene.unload()
    end
    if scenes[title] then
        currentScene = scenes[title]
        currentScene.load(data)
    end
end

function updateCurrentScene(dt)
    currentScene.update(dt)
end

function drawCurrentScene()
    currentScene.draw()
end

function keypressed(key)
    currentScene.keypressed(key)
end

function mousepressed(x, y, button)
    currentScene.mousepressed(x, y, button)
end

function gamepadpressed(joystick, button)
    currentScene.gamepadpressed(joystick, button)
end
