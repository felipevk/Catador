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

    self.out = false

    self.s = 1

    self.spawnRoutine = self.timer:every(opts.timeToSpawn,
            function()
                self:spawn()
            end)

    --[[self.spawnForces = {
        {100000, -50000},
        {0, 100000}
    }]]

    self.boundaries = {
        {100, 850},
        {100, 1500}
    }

    self.axis = {'y', 'x'}
end

function Spawner:spawn()
    local col = self.area:addGameObject('Collectable', self.x, self.y, {
        sprite = sprites.car1,
        colW = 280,
        colH = 184,
        modifiers = self.modifiers,
        drop = self.drop
    })

    -- I have no idea how this worked. This method should be called on the collider and not the gameobject
    col:applyForce(unpack(self.spawnForces[self.gameMode]))
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
end

return Spawner
