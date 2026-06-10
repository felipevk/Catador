local CollisionEffect = GameObject:extend()
local unpack = _G.unpack or table.unpack

function CollisionEffect:new(area, x, y, opts)
    CollisionEffect.super.new(self, area, x, y, opts)

    self.a = 0
    self.timer = Timer()

    self.depth = 100

    self.duration = opts.duration

    self.out = false

    self.particles = {}

    self.speed = opts.speed or 100

    self.h = opts.h or 20

    self.color = opts.color or colors.pink

    local particlesCount = love.math.random(opts.min or 5, opts.max or 10)

    for i = 1, particlesCount do
        local p = { pos = { x = self.x, y = self.y }, r = random(0, 2 * math.pi)}
        table.insert(self.particles, p)
    end

    self.timer:after(
        self.duration * 0.85,
        function()
            self.out = true
            self.timer:tween(self.duration * 0.15, self, {a = 1} , 'in-out-cubic', function() self:die() end)
        end
    )
end

function CollisionEffect:update(dt)
    CollisionEffect.super.update(self, dt)
    if self.timer then self.timer:update(dt) end

    for _, p in ipairs(self.particles) do
        p.pos = movePointDistanceAngle(p.pos.x, p.pos.y, self.speed * dt, p.r)
    end
end 

function CollisionEffect:draw()
    love.graphics.setColor(unpack(self.color))
    love.graphics.setLineWidth(3)
    local height = self.h * ( 1 - self.a )
    for _, p in ipairs(self.particles) do
        local startL =  p.pos
        local endL =  movePointDistanceAngle(p.pos.x, p.pos.y, -height, p.r)
        love.graphics.line(startL.x, startL.y, endL.x, endL.y)
    end
    
    love.graphics.setColor(1,1,1,1)
end

function CollisionEffect:destroy()
   CollisionEffect.super.destroy(self)
end

function CollisionEffect:die()
    self.dead = true
end

return CollisionEffect
