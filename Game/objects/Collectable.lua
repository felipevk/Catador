local Collectable = GameObject:extend()

function Collectable:new(area, x, y, opts)
    Collectable.super.new(self, area, x, y, opts)

    self.sprite = opts.sprite
    self.colW, self.colH = opts.colW, opts.colH
    self.play = opts.play

    self.collider = self.area.world:newRectangleCollider(
        self.x - self.colW / 2, 
        self.y - self.colH / 2, 
        self.colW, self.colH
    )

    self.collider:setCollisionClass('Collectable')
    self.collider:setObject(self)
    self.collider:setFixedRotation(false)
    self.collider:setSleepingAllowed(false)
end

function Collectable:applyForce(x, y)
    self.collider:applyLinearImpulse(x, y)
end 

function Collectable:update(dt)
    Collectable.super.update(self, dt)
end 

function Collectable:draw()
    love.graphics.draw(self.sprite, self.collider:getX(), self.collider:getY(), self.collider:getAngle(), 1, 1, self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
    if debug then
        love.graphics.setColor(1, 0, 0, 1)
        draft:square(self.collider:getX(), self.collider:getY(), 30, 'fill')
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Collectable:die()
    self.dead = true
 end

function Collectable:destroy()
   Collectable.super.destroy(self)
end

return Collectable
