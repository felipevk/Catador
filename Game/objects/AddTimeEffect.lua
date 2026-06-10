local AddTimeEffect = GameObject:extend()
local unpack = _G.unpack or table.unpack

function AddTimeEffect:new(area, x, y, opts)
    AddTimeEffect.super.new(self, area, x, y, opts)

    self.a = 0
    self.timer = Timer()

    self.depth = 100

    self.duration = opts.duration

    self.out = false

    self.particles = {}

    self.h = opts.h

    self.color = opts.color or colors.blue

    local particlesCount = love.math.random(opts.min or 5, opts.max or 10)

    for i = 1, particlesCount do
        local p = { pos = { x = self.x + love.math.random(-100, 100), y = self.y + love.math.random(-100, 100) }}
        table.insert(self.particles, p)
    end

    self.r = math.pi / 2
    self.s = 1

    self.timer:tween(
        self.duration * 0.85, 
        self, {r = (math.pi / 2) + (2 * math.pi)} , 'linear', 
        function() 
            self.timer:tween(self.duration * 0.15, self, {s = 0} , 'in-out-cubic', function() self:die() end)
        end
    )
end

function AddTimeEffect:update(dt)
    AddTimeEffect.super.update(self, dt)
    if self.timer then self.timer:update(dt) end
end 

function AddTimeEffect:draw()
    love.graphics.setLineWidth(3)
    for _, p in ipairs(self.particles) do
        local startL =  p.pos
        local endL =  movePointDistanceAngle(p.pos.x, p.pos.y, self.h * self.s * 0.7, self.r)

        local bgColor = {1, 1, 1, 0.7}
        love.graphics.setColor(unpack(bgColor))
        draft:circle(p.pos.x, p.pos.y, self.h * self.s * 2, 20, 'fill')

        love.graphics.setColor(unpack(self.color))
        love.graphics.line(startL.x, startL.y, endL.x, endL.y)
        draft:circle(p.pos.x, p.pos.y, self.h * self.s * 2, 20, 'line')
    end
    
    love.graphics.setColor(1,1,1,1)
end

function AddTimeEffect:destroy()
   AddTimeEffect.super.destroy(self)
end

function AddTimeEffect:die()
    self.dead = true
end

return AddTimeEffect
