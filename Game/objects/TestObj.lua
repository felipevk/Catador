local TestObj = GameObject:extend()
local unpack = _G.unpack or table.unpack

function TestObj:new(area, x, y, opts)
    TestObj.super.new(self, area, x, y, opts)
end

function TestObj:update(dt)
    TestObj.super.update(self, dt)
end 

function TestObj:draw()
    local sprite = sprites.sun
    --love.graphics.setColor(unpack(colors.purple))
    love.graphics.draw(sprite, self.x, self.y, 0, 1, 1, sprite:getWidth() / 2, sprite:getHeight() / 2)
    if debug then
        love.graphics.setColor(1, 0, 0, 1)
        draft:square(self.x, self.y, 30, 'fill')
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function TestObj:destroy()
   TestObj.super.destroy(self)
end

return TestObj