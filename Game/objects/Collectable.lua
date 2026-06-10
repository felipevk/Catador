local Collectable = GameObject:extend()
local unpack = _G.unpack or table.unpack

function Collectable:new(area, x, y, opts)
    Collectable.super.new(self, area, x, y, opts)

    self.modifiers = opts.modifiers

    self.drop = opts.drop

    self.sprite = opts.sprite
    self.colW, self.colH = opts.colW, opts.colH

    self.depth = opts.depth

    self.collider = self.area.world:newRectangleCollider(
        self.x - self.colW / 2, 
        self.y - self.colH / 2, 
        self.colW, self.colH
    )

    self.collider:setCollisionClass('Collectable')
    self.collider:setObject(self)
    self.collider:setFixedRotation(false)
    self.collider:setSleepingAllowed(false)
    if self.modifiers.bouncy then self.collider:setRestitution(0.8) end

    self.consumed = false
    self.out = false
    self.s = 1
    self.isAttached = false
    self.jointID = -1
    self.split = false

    if self.modifiers.homing then
        self.timer:every(1,
            function()
                local aToB = { self.drop.x - self.x, self.drop.y - self.y }
                local dir = getUnitVector(unpack(aToB))
                local magnitude = 100000
                --print(self.drop)
                self.collider:applyForce(dir.x * magnitude * self.colW, dir.y * magnitude * self.colH)
            end)
    end
end

function Collectable:consume()
    self.consumed = true

    self:transitionOut()
end 


function Collectable:transitionOut()
    if self.out then return end
    self.out = true
    --self.collider:setLinearVelocity(0, 0)
    self.collider:setSensor(true)
    --self.collider:setType('kinematic')
    --if self.isAttached then self.player:clearJoint(self.jointID) end

    self.timer:tween(1.0, self, {s = 0}, 'in-out-cubic',
        function() 
            self:die()
        end)
end

function Collectable:applyForce(x, y)
    self.collider:applyLinearImpulse(x, y)
end 

function Collectable:update(dt)
    Collectable.super.update(self, dt)

    if self.consumed then
        local aToB = { self.drop.x - self.x, self.drop.y - self.y }
        local dir = getUnitVector(unpack(aToB))
        local dist = getVectorMagnitude(unpack(aToB))
        local magnitude = 0.009 * dist
        self.collider:setLinearVelocity(dir.x * magnitude * self.colW, dir.y * magnitude * self.colH)
        return
    end
end 

function Collectable:draw()
    love.graphics.draw(self.sprite, self.collider:getX(), self.collider:getY(), self.collider:getAngle(), self.s, self.s, self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
    if debug then
        if self.split then love.graphics.setColor(0, 0, 0.8, 1)  else love.graphics.setColor(1, 0, 0, 1) end
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
