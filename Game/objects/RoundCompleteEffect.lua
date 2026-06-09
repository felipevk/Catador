local RoundCompleteEffect = GameObject:extend()
local unpack = _G.unpack or table.unpack

function RoundCompleteEffect:new(area, x, y, opts)
    RoundCompleteEffect.super.new(self, area, x, y, opts)

    self.x, self.y = gw /2 , gh / 2
    self.scale = 0.5
    self.a = 0
    self.timer = Timer()

    self.depth = 400

    self.sprite = sprites.square

    self.squares = {}

    self.count = 30

    for i = 1, self.count do
        local squareData = {
            --color = (i % 2 == 0) and colors.green or colors.blue,
            s =  -0.5 * i,
            r =  (i / self.count) * math.pi,
            x = gw + (self.count * (i - 1)),
            y = gh + (self.count * (i - 1))
            --x = gw / 2,
            --y = gh  / 2
        }
        table.insert(self.squares, squareData)
    end

    self.animating = false
    self.win = false
end

function RoundCompleteEffect:show(duration, isWin)
    self.animating = true
    self.win = isWin
    self.timer:tween(duration, self, {a = 1}, 'in-out-cubic')
end 

function RoundCompleteEffect:hide(duration)
    self.timer:tween(duration, self, {a = 0, scale = 1}, 'in-out-cubic', function() self.animating = false end)
end 

function RoundCompleteEffect:getMainColor()
    return (self.win) and colors.green or colors.red
end 

function RoundCompleteEffect:update(dt)
    RoundCompleteEffect.super.update(self, dt)
    if self.timer then self.timer:update(dt) end
end 

function RoundCompleteEffect:draw()
    if not self.animating then return end
    for i, data in ipairs(self.squares) do
        --if i > 5 then break end
        local size = data.s + self.a * 140
        local color = (i % 2 == 0) and self:getMainColor() or colors.orange
        if size < 0 then break end
        love.graphics.setColor(unpack(color))
        love.graphics.draw(
            self.sprite, 
            data.x - self.a * gw / 2 * 1, data.y - self.a * gh / 2 * 1, 
            data.r + self.a * math.pi * 2, 
            size, size, 
            self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
    end
    --love.graphics.setColor(0,1,0,self.a)
    --love.graphics.draw(sprites.bowler, self.x, self.y, 0, self.scale, self.scale, sprites.bowler:getWidth() / 2, sprites.bowler:getHeight() / 2)
    love.graphics.setColor(1,1,1, 1)
end

function RoundCompleteEffect:destroy()
   RoundCompleteEffect.super.destroy(self)
end

return RoundCompleteEffect
