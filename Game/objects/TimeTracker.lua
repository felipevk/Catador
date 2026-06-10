local TimeTracker = GameObject:extend()

function TimeTracker:new(area, x, y, opts)
    TimeTracker.super.new(self, area, x, y, opts)

    self.counting = false
    self.timeLeft = 0
    self.totalTime = 0
    self.play = opts.play

    self.s = 0.75
end

function TimeTracker:start(time)
    self.counting = true
    self.timeLeft = time
    self.totalTime = time
end

function TimeTracker:stop()
    self.counting = false
end

function TimeTracker:addTime(amount)
    self.totalTime = self.totalTime + amount
    self.timeLeft = self.timeLeft + amount
end

function TimeTracker:update(dt)
    TimeTracker.super.update(self, dt)

    if not self.counting then return end

    self.timeLeft = self.timeLeft - dt

    if self.timeLeft <= 0 then
        self.timeLeft = 0
        self.play:finishLevel(self.play.gameMode == GameModes.DEFENSE)
    end
end 

-- each past second moves the images one height

function TimeTracker:draw()
    --love.graphics.setColor(1, 0, 0, 1)

    local timeLeftInt = math.floor(self.timeLeft)
    local totalTimeInt = math.floor(self.totalTime)

    for i = 1, totalTimeInt do
        local initialY = self.y - (sprites.sun:getHeight() * self.s * (i - 1))
        local timeDisplacedY = initialY + ((self.totalTime - self.timeLeft ) * sprites.sun:getHeight() * self.s) - 40
        love.graphics.draw(sprites.sun, self.x, timeDisplacedY, 0, self.s, self.s, sprites.sun:getWidth() * self.s / 2, sprites.sun:getHeight() * self.s / 2)
    end

    if debug then
        love.graphics.setColor(1, 0, 0, 1)
        draft:square(self.x, self.y, 30, 'fill')
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function TimeTracker:destroy()
   TimeTracker.super.destroy(self)
end

return TimeTracker
