local Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)

    self.x, self.y = x, y

    self.sprite = sprites.hand1
    self.w, self.h = self.sprite:getWidth(), self.sprite:getHeight()

    self.collider = self.area.world:newRectangleCollider(self.x , self.y, self.w, self.h)
    self.collider:setCollisionClass('Player')
    self.collider:setFixedRotation(true)
    self.collider:setType('kinematic')

    self.isClick = false
end

function Player:update(dt)
    Player.super.update(self, dt)

    local clicking = input:down('click') == true

    if clicking ~= self.isClick then
        self:ToggleClick(clicking)
    end

    self.x = love.mouse.getX() / sx
    self.y = love.mouse.getY() / sy

    self.collider:setX(self.x)
    self.collider:setY(self.y)
end 

function Player:ToggleClick(toggle)
    self.isClick = toggle

    self.collider:setSensor(self.isClick)
end

function Player:draw()
    love.graphics.setColor(1, 1, 1, self.isClick and 0.5 or 1)
    love.graphics.draw(self.sprite, self.x, self.y, 0, nil, nil, self.w / 2, self.h / 2)
    love.graphics.setColor(1, 1, 1, 1)
end

function Player:destroy()
   Player.super.destroy(self)
end

return Player
