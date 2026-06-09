local TimeTracker = GameObject:extend()

function TimeTracker:new(area, x, y, opts)
    TimeTracker.super.new(self, area, x, y, opts)

    self.counting = false
    self.timeLeft = 0
    self.totalTime = 0
    self.play = opts.play
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

function TimeTracker:draw()
    love.graphics.setColor(1, 0, 0, 1)
    local demoFont = love.graphics.newFont(40)
    love.graphics.setFont(demoFont)
    printInsideRect("Time Left: " .. math.floor(self.timeLeft), demoFont, "topRight")
    love.graphics.setColor(1, 1, 1, 1)
end

function TimeTracker:destroy()
   TimeTracker.super.destroy(self)
end

return TimeTracker
