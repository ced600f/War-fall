require("objects")
local tank = require("tank")
local Game = {}
local MAP_WIDTH = 15
local MAP_HEIGHT = 8
TILE_WIDTH = 128
TILE_HEIGHT = 135

Game.nbSpawn = 1
Game.delaySpawn = 0

Game.timerSpawn = nil
Game.timerNBSpawn = nil

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
Game.TileType = {}

function Game.spawn()
    math.randomseed(os.time())
    for i = 1, Game.nbSpawn do
        spawnEnemy()
    end
    Game.delaySpawn = math.random(2, 10)
    Game.timerSpawn = newTimer(Game.delaySpawn, Game.spawn)
    Game.timerSpawn.start()
end

function Game.addSpawn()
    math.randomseed(os.time())
    Game.nbSpawn = Game.nbSpawn + 1
    Game.timerNBSpawn = newTimer(math.random(10, 20), Game.addSpawn)
    Game.timerNBSpawn.start()
end

function Game.load()
    Game.TileSheet = love.graphics.newImage("images/tiles/tiles.png")
    local nCols = Game.TileSheet:getWidth() / TILE_WIDTH
    local nLines = Game.TileSheet:getHeight() / TILE_HEIGHT

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

    Game.TileType[1] = "Left upper corner"
    Game.TileType[2] = "Upper border"
    Game.TileType[3] = "Right upper corner"
    Game.TileType[8] = "Left border"
    Game.TileType[9] = "Ground"
    Game.TileType[10] = "Right border"

    math.randomseed(os.time())
    Game.delaySpawn = math.random(0, 10)
    Game.timerSpawn = newTimer(Game.delaySpawn, Game.spawn)
    Game.timerSpawn.start()
    Game.timerNBSpawn = newTimer(math.random(10, 20), Game.addSpawn)
    Game.timerNBSpawn.start()
end

function Game.update(dt)
    Game.timerSpawn.update(dt)
    Game.timerNBSpawn.update(dt)
    tank.update(dt)

    updateEnemies(dt)
    updateBullets(dt)
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
    love.graphics.print(Game.timerSpawn.delay .. " - " .. Game.timerSpawn.currentTime, 10, 10)
    love.graphics.print(
        Game.nbSpawn .. " - " .. Game.timerNBSpawn.delay .. " - " .. Game.timerNBSpawn.currentTime,
        10,
        40
    )
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
