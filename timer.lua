-- Gestion de timers aléatoires
-- Chaque timer peut être relancé automatiquement avec un délai aléatoire
-- situé entre le minimum et le maximum
local timers = {}

function updateTimers(dt)
    for _, timer in ipairs(timers) do
        timer.update(dt)
    end
end

function newTimer(delayMin, delayMax, callback, restart)
    local timer = {}
    timer.currentTime = 0
    timer.started = false
    timer.minimum = delayMin
    timer.maximum = delayMax
    if restart == nil then
        restart = true
    end
    timer.restart = restart

    timer.update = function(dt)
        if timer.started == true then
            timer.currentTime = timer.currentTime + dt
            if timer.expired() == true then
                timer.started = false
                timer.callback()
                -- on redémarre le timer aléatoirement
                if timer.restart == true then
                    timer.start()
                end
            end
        end
    end

    timer.setDelays = function(min, max)
        timer.minimum = min
        timer.maximum = max
    end

    timer.expired = function()
        return timer.currentTime >= timer.delay
    end

    timer.start = function()
        timer.delay = math.random(timer.minimum, timer.maximum)
        timer.currentTime = 0
        timer.started = true
    end

    timer.callback = callback

    table.insert(timers, timer)
    if timer.restart == true then
        timer.start()
    end

    return timer
end
