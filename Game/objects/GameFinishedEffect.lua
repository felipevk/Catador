local GameFinishedEffect = GameObject:extend()
local unpack = _G.unpack or table.unpack

function GameFinishedEffect:new(area, x, y, opts)
    GameFinishedEffect.super.new(self, area, x, y, opts)

    self.x, self.y = gw /2 , gh / 2
    self.scale = 0.5
    self.a = 0
    self.timer = Timer()

    self.depth = 400

   self.timer:tween(0.5, self, {a = 1, scale = 1}, 'in-out-cubic')

   sounds.cheer:play()
end

function GameFinishedEffect:update(dt)
    GameFinishedEffect.super.update(self, dt)
    if self.timer then self.timer:update(dt) end
end 

function GameFinishedEffect:draw()
    love.graphics.setColor(unpack(colors.yellow))
    love.graphics.draw(sprites.trophy, self.x, self.y, 0, self.scale, self.scale, sprites.trophy:getWidth() / 2, sprites.trophy:getHeight() / 2)
    love.graphics.setColor(1,1,1,1)
end

function GameFinishedEffect:destroy()
   GameFinishedEffect.super.destroy(self)
end

return GameFinishedEffect
