function newTimer(delay, callback)
    local timer = {}
    timer.currentTime = 0
    timer.started = false
    timer.delay = delay
    timer.callback = callback

    timer.update = function(dt)
        if timer.started == true then
            timer.currentTime = timer.currentTime + dt
            if timer.expired() == true then
                timer.started = false
                timer.callback()
            end
        end
    end

    timer.expired = function()
        return timer.currentTime >= timer.delay
    end

    timer.start = function()
        timer.currentTime = 0
        timer.started = true
    end

    return timer
end
