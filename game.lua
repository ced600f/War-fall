require("objects")
require("timer")
require("coin")
require("bonus")

local tank = require("tank")
local Game = {}
local MAP_WIDTH = 15
local MAP_HEIGHT = 8
TILE_WIDTH = 128
TILE_HEIGHT = 135

Game.nbSpawn = 0

Game.Map = {}
Game.Map = {
    {0, 1, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 2, 3, 0},
    {0, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 0},
    {0, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 0},
    {0, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 0},
    {0, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 0},
    {0, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 0},
    {0, 4, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 5, 6, 0},
    {0, 7, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 8, 9, 0}
}

Game.TileSheet = nil

Game.TileTextures = {}

function Game.spawn()
    for i = 1, Game.nbSpawn do
        spawnEnemy()
    end
end

function Game.addSpawn()
    Game.nbSpawn = Game.nbSpawn + 1
end

function Game.addCoin()
    newCoin()
end

function Game.addBonus()
    newBonus()
end

function Game.load()
    initObjects()
    initBonus()

    Game.TileSheet = love.graphics.newImage("images/tiles/tiles.png")
    local nCols = Game.TileSheet:getWidth() / TILE_WIDTH
    local nLines = Game.TileSheet:getHeight() / TILE_HEIGHT
    Game.Music = love.audio.newSource("Sons/Instrumental.mp3", "stream")
    Game.Music:setVolume(0.7)

    local l, c
    local id = 1

    Game.TileTextures[0] = nil
    for l = 1, nLines do
        for c = 1, nCols do
            local texture =
                love.graphics.newQuad(
                (c - 1) * TILE_WIDTH,
                (l - 1) * TILE_HEIGHT,
                TILE_WIDTH,
                TILE_HEIGHT,
                Game.TileSheet:getWidth(),
                Game.TileSheet:getHeight()
            )

            Game.TileTextures[id] = texture
            id = id + 1
        end
    end

    -- Si le tank colisionne avec un objet dès le début
    -- On le déplace aléatoirement
    while checkVehicleCollision(tank) do
        tank.x = math.random(MARGIN, SCREEN_WIDTH - MARGIN)
        tank.y = math.random(MARGIN, SCREEN_HEIGHT - MARGIN)
    end

    Game.nbSpawn = 1
    newTimer(5, 20, Game.spawn)
    newTimer(15, 30, Game.addSpawn)
    newTimer(7, 15, Game.addCoin)
    newTimer(15, 60, Game.addBonus)
    Game.Music:stop()
    Game.Music:play()
end

function Game.update(dt)
    updateTimers(dt)

    tank.update(dt)

    updateEnemies(dt)
    updateBullets(dt)
    updateObjects(dt)
    updateCoins(dt)
end

function Game.draw()
    local c, l

    for l = 1, MAP_HEIGHT do
        for c = 1, MAP_WIDTH do
            local id = Game.Map[l][c]
            local texQuad = Game.TileTextures[id]
            if texQuad ~= nil then
                love.graphics.draw(Game.TileSheet, texQuad, ((c - 1) * TILE_WIDTH), ((l - 1) * TILE_HEIGHT))
            end
        end
    end

    drawObjects()
    drawCoins()
    drawBonus()
end

function GetTile(x, y)
    local c = math.floor(x / TILE_WIDTH) + 1
    local l = math.floor(y / TILE_HEIGHT) + 1
    local retour = "Hors du tableau"
    if c <= 0 then
        c = 1
    end
    if l <= 0 then
        l = 1
    end
    if c <= MAP_WIDTH and l <= MAP_HEIGHT then
        retour = Game.Map[l][c]
    end

    return retour
end

return Game
