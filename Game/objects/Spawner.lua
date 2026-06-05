local Spawner = GameObject:extend()

function Spawner:new(area, x, y, opts)
    Spawner.super.new(self, area, x, y, opts)

    self.sprite = opts.sprite

    self.dir = 100

    self.timer:every(opts.timeToSpawn,
            function()
                self:spawn()
            end)
end

function Spawner:spawn()
    col = self.area:addGameObject('Collectable', self.x, self.y + 80, {
        sprite = sprites.car1,
        colW = sprites.car1:getWidth(),
        colH = sprites.car1:getHeight(),
        play = self
    })

    col:applyForce(0,100000)
end

function Spawner:update(dt)
    Spawner.super.update(self, dt)

    self.x = self.x + self.dir * dt

    if self.x > 1500 or self.x < 100 then
        self.dir = self.dir * -1
    end
end 

function Spawner:draw()
    love.graphics.draw(self.sprite, self.x, self.y, 0, nil, nil, self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
    if debug then
        love.graphics.setColor(1, 0, 0, 1)
        draft:square(self.x, self.y, 30, 'fill')
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Spawner:destroy()
   Spawner.super.destroy(self)
end

return Spawner
