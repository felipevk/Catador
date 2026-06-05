local Player = GameObject:extend()

function Player:new(area, x, y, opts)
    Player.super.new(self, area, x, y, opts)

    self.x, self.y = x, y

    self.handCount = opts.hands

    self.handData = {
        {sprite = { asset = sprites.hand1, position = {x = 0, y = 0} }, collider={x = 0, y = 0, w = 194, h = 74}},
        {sprite = { asset = sprites.hand1, position = {x = 300, y = 0} }, collider={x = 300, y = 0, w = 194, h = 74}},
        {sprite = { asset = sprites.hand1, position = {x = 80, y = -270} }, collider={x = 80, y = -270, w = 194, h = 74}},
        {sprite = { asset = sprites.hand1, position = {x = -250, y = 0} }, collider={x = -250, y = 0, w = 194, h = 74}},
        {sprite = { asset = sprites.hand1, position = {x = 100, y = 20} }, collider={x = 100, y = 20, w = 194, h = 74}},
        {sprite = { asset = sprites.hand1, position = {x = -200, y = -150} }, collider={x = -200, y = -150, w = 194, h = 74}}
    }

    self.colliders = {}
    self.sprites = {}

    for i = 1, self.handCount do
        self.sprites[i] = self.handData[i].sprite.asset

        self.colliders[i] = self.area.world:newRectangleCollider(
            self.x + self.handData[i].collider.x , 
            self.y + self.handData[i].collider.y, 
            self.handData[i].collider.w, 
            self.handData[i].collider.h)

        self.colliders[i]:setCollisionClass('Player')
        self.colliders[i]:setFixedRotation(true)
        self.colliders[i]:setType('kinematic')
    end

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

    for i = 1, self.handCount do
        self.colliders[i]:setX(self.x + self.handData[i].collider.x)
        self.colliders[i]:setY(self.y + self.handData[i].collider.y)
    end
end 

function Player:ToggleClick(toggle)
    self.isClick = toggle

    for i = 1, self.handCount do
        self.colliders[i]:setSensor(self.isClick)
    end
end

function Player:draw()
    love.graphics.setColor(1, 1, 1, self.isClick and 0.5 or 1)
    for i = 1, self.handCount do
        local spriteData = self.handData[i].sprite
        love.graphics.draw(
            spriteData.asset, 
            self.x + spriteData.position.x, 
            self.y + spriteData.position.y, 
            0, nil, nil, 
            spriteData.asset:getWidth() / 2, 
            spriteData.asset:getHeight() / 2)

        self.colliders[i]:setX(self.x + self.handData[i].collider.x)
        self.colliders[i]:setY(self.y + self.handData[i].collider.y)
    end
    --love.graphics.draw(self.sprite, self.x, self.y, 0, nil, nil, self.w / 2, self.h / 2)
    love.graphics.setColor(1, 1, 1, 1)
end

function Player:destroy()
   Player.super.destroy(self)
end

return Player
