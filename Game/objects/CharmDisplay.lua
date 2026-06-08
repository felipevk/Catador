local CharmDisplay = GameObject:extend()
local unpack = _G.unpack or table.unpack

function CharmDisplay:new(area, x, y, opts)
    CharmDisplay.super.new(self, area, x, y, opts)

    self.charmData = {}
    self.colliders = {}
    self.joints = {}
    self.s = 0.4

    self.depth = 9
end

function CharmDisplay:setCharms(activeCharmsData)
    if self.colliders then
        for _, collider in ipairs(self.colliders) do
            collider:destroy()
        end
        self.colliders = {}
    end

    if self.joints then
        for _,joint in ipairs(self.joints) do
            if joint and not joint:isDestroyed() then
                joint:destroy()
            end
        end
        self.joints = {}
    end

    self.charmData = activeCharmsData

    for i, charmData in ipairs(self.charmData) do
        local sprite = charmData.sprite
        charmCol = self.area.world:newRectangleCollider(
            self.x - sprite:getWidth() / 2 * self.s, 
            self.y + ( ( i - 1 ) * sprite:getHeight() * self.s * 1.7 ) , 
            sprite:getWidth() * self.s, 
            sprite:getHeight() * self.s)

        charmCol:setCollisionClass('CharmDisplay')
        charmCol:setFixedRotation(false)
        charmCol:setType((i == 1) and 'static' or 'dynamic')

        if i > 1 then
            local previousCol = self.colliders[i-1]

            local joint = love.physics.newRopeJoint(
                charmCol.body,
                previousCol.body,
                charmCol:getX() + sprite:getWidth() / 2 * self.s, 
                charmCol:getY() - sprite:getHeight() / 2 * self.s,
                previousCol:getX(), 
                previousCol:getY() + sprite:getHeight() / 2 * self.s,
                10,
                true
            )
            table.insert(self.joints, joint)
        end

        table.insert(self.colliders, charmCol)
    end
end

function CharmDisplay:update(dt)
    CharmDisplay.super.update(self, dt)
end 

function CharmDisplay:draw()
    love.graphics.setColor(1, 1, 1, 1)
    for i, charmData in ipairs(self.charmData) do
        love.graphics.setColor(unpack(charmData.color))
        local sprite = charmData.sprite
        local collider = self.colliders[i]
        love.graphics.draw(
            sprite, 
            collider:getX(), 
            collider:getY(), 
            collider:getAngle(), self.s, self.s, 
            sprite:getWidth() / 2, 
            sprite:getHeight() / 2)
    end

    if debug then
        love.graphics.setColor(1, 0, 0, 1)
        draft:square(self.x, self.y, 30, 'fill')
        love.graphics.setColor(1, 1, 1, 1)
    end

    love.graphics.setColor(colors.blue)
    for i, joint in ipairs(self.joints) do
        if joint and not joint:isDestroyed() then
            local x1, y1, x2, y2 = joint:getAnchors()
            love.graphics.setLineWidth(5)
            love.graphics.line(x1, y1, x2, y2)
        end
    end
    love.graphics.setColor(1, 1, 1, 1)
end

function CharmDisplay:destroy()
   CharmDisplay.super.destroy(self)
   for _,joint in ipairs(self.joints) do
        if joint and not joint:isDestroyed() then
            joint:destroy()
        end
    end
    self.joints = {}

    for _, collider in ipairs(self.colliders) do
        collider:destroy()
    end
    self.colliders = {}
end

return CharmDisplay
