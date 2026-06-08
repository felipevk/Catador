local Score = GameObject:extend()

function Score:new(area, x, y, opts)
    Score.super.new(self, area, x, y, opts)

    self.play = opts.play
    self.modifiers = opts.modifiers
    self.timeTracker = opts.timeTracker
end

function Score:start(goal)
    self.points = 0
    self.goal = goal * self.modifiers.goalScoreMult
end 

function Score:update(dt)
    Score.super.update(self, dt)
end 

function Score:draw()
    local demoFont = love.graphics.newFont(40)
    love.graphics.setFont(demoFont)
    printInsideRect("Score: " .. self.points .. " / " .. self.goal, demoFont, "bottomLeft")
end

function Score:add(points)
    self.points = self.points + points

    if self.points >= self.goal then
        self.play:finishLevel(self.play.gameMode == GameModes.ATTACK)
    end

    if self.modifiers.increaseTimeWithScore then
        if points >= 1 then self.timeTracker:addTime(2) end
    end
end

function Score:destroy()
   Score.super.destroy(self)
end

return Score