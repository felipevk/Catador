local Spawner = GameObject:extend()
local unpack = _G.unpack or table.unpack

function Spawner:new(area, x, y, opts)
    Spawner.super.new(self, area, x, y, opts)

    self.gameMode = opts.gameMode

    self.sprite = opts.sprite

    self.depth = opts.depth

    self.modifiers = opts.modifiers

    self.drop = opts.drop

    self.velocity = opts.velocity or 100
    self.spawnForces = opts.spawnForces

    self.collectableData = opts.collectableData

    self.out = false

    self.s = 1

    self.spawnRoutine = self.timer:every(opts.timeToSpawn,
            function()
                self:spawn()
            end)

    self.boundaries = {
        {100, 850},
        {100, 1500}
    }

    self.axis = {'y', 'x'}

    self.spawnedObjs = 1

    self.sound = sounds.spawn:clone()
end

function Spawner:spawn()
    local randomCollectableData = self.collectableData[love.math.random(#self.collectableData)]

    local col = self.area:addGameObject('Collectable', self.x, self.y, {
        sprite = randomCollectableData.sprite,
        colW = randomCollectableData.w,
        colH = randomCollectableData.h,
        modifiers = self.modifiers,
        drop = self.drop,
        depth = self.depth + (self.spawnedObjs * 0.5)
    })

    -- I have no idea how this worked. This method should be called on the collider and not the gameobject
    local initialForce = self.spawnForces[self.gameMode]
    initialForce.x = initialForce[1]
    initialForce.y = initialForce[2]
    col.collider:setLinearVelocity(unpack(initialForce))

    self.spawnedObjs = self.spawnedObjs + 1

    self.sound:play()
end

function Spawner:update(dt)
    Spawner.super.update(self, dt)

    local currAxis = self.axis[self.gameMode]
    local min, max = unpack(self.boundaries[self.gameMode])
    
    self[currAxis] = self[currAxis] + self.velocity * dt

    if self[currAxis] < min or self[currAxis]> max then
        self.velocity = self.velocity * -1
    end
end 

function Spawner:draw()
    love.graphics.draw(self.sprite, self.x, self.y, 0, self.s, self.s, self.sprite:getWidth() / 2, self.sprite:getHeight() / 2)
    if debug then
        love.graphics.setColor(1, 0, 0, 1)
        draft:square(self.x, self.y, 30, 'fill')
        love.graphics.setColor(1, 1, 1, 1)
    end
end

function Spawner:transitionOut()
    if self.out then
        return
    end
    self.out = true

    self.timer:cancel(self.spawnRoutine)

    self.timer:tween(1.0, self, {s = 0}, 'in-out-cubic',
        function() 
            self:die()
        end)
end

function Spawner:die()
    self.dead = true
end

function Spawner:destroy()
   Spawner.super.destroy(self)

   self.sound = nil
end

return Spawner
