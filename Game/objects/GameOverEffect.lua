local GameOverEffect = GameObject:extend()

function GameOverEffect:new(area, x, y, opts)
    GameOverEffect.super.new(self, area, x, y, opts)

    self.x, self.y = gw /2 , gh / 2
    self.scale = 0.5
    self.a = 0
    self.timer = Timer()

   self.timer:tween(0.5, self, {a = 1, scale = 1}, 'in-out-cubic',
    function()
        self.timer:after(1.5, function()
            self.timer:tween(0.25, self, {a = 0}, 'in-out-cubic',
            function()
                self.dead = true
            end)
        end)
    end)
end

function GameOverEffect:update(dt)
    GameOverEffect.super.update(self, dt)
    if self.timer then self.timer:update(dt) end
end 

function GameOverEffect:draw()
    love.graphics.setColor(1,0,0,self.a)
    love.graphics.draw(sprites.bowler, self.x, self.y, 0, self.scale, self.scale, sprites.bowler:getWidth() / 2, sprites.bowler:getHeight() / 2)
    love.graphics.setColor(1,1,1, 1)
end

function GameOverEffect:destroy()
   GameOverEffect.super.destroy(self)
end

return GameOverEffect
