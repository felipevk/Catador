local Score = GameObject:extend()
local unpack = _G.unpack or table.unpack

function Score:new(area, x, y, opts)
    Score.super.new(self, area, x, y, opts)

    self.play = opts.play
    self.modifiers = opts.modifiers
    self.timeTracker = opts.timeTracker

    self.showing = false

    self.a = 0

    self.goalSprite = sprites.notch
    self.pointsSprite = sprites.star
end

function Score:show(goal)
    self.points = 0
    self.goal = goal * self.modifiers.goalScoreMult
    self.showing = true
    self.dropPos = { self.play.drop.x, self.play.drop.y }
    self.goalColor = (self.play.gameMode == GameModes.ATTACK) and colors.red or colors.green
    self.pointsColor = (self.play.gameMode == GameModes.ATTACK) and colors.green or colors.red
end 

function Score:hide()
    self.showing = false
end 

function Score:update(dt)
    Score.super.update(self, dt)
end 

function Score:draw()
    if not self.showing then return end
    local space = 10
    love.graphics.setColor(unpack(self.goalColor))
    for i = 1 , self.goal do
        local xDisplaced = self.x + ( ( self.goalSprite:getWidth() + space ) * (i - 1) )
        love.graphics.draw(self.goalSprite, xDisplaced, self.y, 0, 1, 1, self.goalSprite:getWidth() / 2, self.goalSprite:getHeight() / 2)
    end

    love.graphics.setColor(unpack(self.pointsColor))
    for i = 1 , self.points do
        local xDisplaced = self.x + ( ( self.pointsSprite:getWidth() + space ) * (i - 1) )
        love.graphics.draw(self.pointsSprite, xDisplaced, self.y, 0, 1, 1, self.pointsSprite:getWidth() / 2, self.goalSprite:getHeight() / 2)
    end

    love.graphics.setColor(1, 1, 1, 1)
end

function Score:add(points)
    self.points = self.points + points

    local flashC = (self.play.gameMode == GameModes.ATTACK) and deepCopyColor(colors.green) or deepCopyColor(colors.red)
    flashC[4] = 0.3
    flash(8, flashC)
    camera:shake(6, 80, 1.0)

    self.timer:tween(0.5, self, {a = 1}, 'in-out-cubic')

    if self.play.gameMode == GameModes.ATTACK then
        sounds.score:play()
    else
        sounds.metal:play()
    end

    --self.timer:after(0.25, function() sounds.vortex:play() end)

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