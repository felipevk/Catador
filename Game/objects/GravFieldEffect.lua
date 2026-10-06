local GravFieldEffect = GameObject:extend()

function GravFieldEffect:new(area, x, y, opts)
    GravFieldEffect.super.new(self, area, x, y, opts)

    self.depth = -15
    self.range = opts.range

    self.vertCount = 30

    self.vertices = {}

    for i = 1, self.vertCount do
        local a = i / self.vertCount
        local angle = a * 2 * math.pi
        table.insert(self.vertices,
        { x = self.x + math.cos(angle) * self.range, y = self.y + math.sin(angle) * self.range })
    end

    local triangles = triangulate(self.vertices, self.x, self.y)

    self.mesh = love.graphics.newMesh(
        triangles,
        "fan",
        "dynamic"
    )

    self.count = 0
    self.speed = 4
    self.moveRange = self.range * 0.05
    self.vertStep = 0.7
end

function triangulate(points, x, y)
    local triangles = {}
    for i = 1, #points do
        local nextI = i % #points + 1

        local triangle = { 
            points[i].x, points[i].y, 
            points[nextI].x, points[nextI].y ,
            x, y
        }

        table.insert(triangles, triangle)
    end

    return triangles
end

function GravFieldEffect:updatePos(x, y)
    self.x = x
    self.y = y
end

function GravFieldEffect:update(dt)
    GravFieldEffect.super.update(self, dt)

    self.count = self.count + dt * self.speed

    for i = 1, #self.vertices do
        local a = i / #self.vertices
        local angle = a * 2 * math.pi
        local delta = math.cos(self.count + i * self.vertStep) * self.moveRange
        self.vertices[i].x = self.x + math.cos(angle) * (self.range + delta)
        self.vertices[i].y = self.y + math.sin(angle) * (self.range + delta)
    end

    local triangles = triangulate(self.vertices, self.x, self.y)

    self.mesh:setVertices(triangles)

    shaders.gField:send("time", love.timer.getTime())
end 

function GravFieldEffect:draw()
    -- love.graphics.setColor(0, 0, 0.8, 1)
    -- for i = 1, #self.vertices do
    --     draft:square(self.vertices[i].x, self.vertices[i].y, 30, 'fill')
    -- end
    --local triangles = triangulate(self.vertices, self.x, self.y)
    -- for _, triangle in ipairs(triangles) do
    --     love.graphics.line(triangle[1], triangle[2], triangle[3], triangle[4])
    --     love.graphics.line(triangle[3], triangle[4], triangle[5], triangle[6])
    --     love.graphics.line(triangle[5], triangle[6], triangle[1], triangle[2])
    -- end
    love.graphics.setShader(shaders.gField)
    love.graphics.draw(self.mesh)
    love.graphics.setShader()
    love.graphics.setColor(1, 1, 1, 1)
end

function GravFieldEffect:die()
    self.dead = true
end

function GravFieldEffect:destroy()
   GravFieldEffect.super.destroy(self)
end

return GravFieldEffect