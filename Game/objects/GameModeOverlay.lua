local GameModeOverlay = GameObject:extend()
local unpack = _G.unpack or table.unpack

function GameModeOverlay:new(area, x, y, opts)
    GameModeOverlay.super.new(self, area, x, y, opts)

    self.backgroundColor = {1.0, 0.0, 0.0, 0.5}
    self.panelColor = {0.0, 0.0, 0.8, 0.9}

    self.x, self.y = gw / 2 , gh / 2

    self.showing = false

    self.onPicked = nil

    self.depth = 500

    self.isSelected = false

    self.speed = 0

    self.min, self.max = gw * 0.2, gw * 0.8

    self.dir = 1

    -- x,y as top left
    self.buttonData = {
        x = gw / 2 - 528 / 2,
        y = 656,
        w = 528,
        h = 156,
        text = "CHOOSE",
        color = {1.0, 1.0, 1.0, 0.9},
        hoveredColor = {0.7, 0.7, 0.7, 0.9},
        textColor = {0.0, 0.0, 0.0, 1.0}
    }

    self.w, self.h = gw * 0.35, gh * 0.5

    self.attackRect = {x = gw / 2 - self.w, y = gh / 2 - self.h / 2, w = self.w, h = self.h }

    self.defendRect = {x = gw / 2, y = gh / 2 - self.h / 2, w = self.w, h = self.h }

    self.timeToHide = 2.0

    self.allowClick = false

end

function GameModeOverlay:show(movementSpeed, callback)
    self.showing = true
    self.onPicked = callback

    self.isSelected = false

    self.speed = movementSpeed

    self.x = self.min

    self.dir = 1

    self.buttonFont = getGameFont()
    self.attackFont = getGameFont()
    self.defendFont = getGameFont()

    self.timer:after(0.5, function() self.allowClick = true end)
end

function GameModeOverlay:update(dt)
    GameModeOverlay.super.update(self, dt)

    if not self.showing then return end

    local clicking = input:down('click') == true

    self.isHovered = self:isAreaHovered(self.buttonData)

    if self.allowClick and self.isHovered and clicking and not self.isSelected then
        self:onClicked()
    end

    if self.isSelected then self.speed = 0 end

    self.x = self.x + (self.speed * dt * self.dir)

    if self.x <= self.min then
        self.x = self.min + 0.1
        self.dir = 1
    end

    if self.x >= self.max then
        self.x = self.max - 0.1
        self.dir = -1
    end

end 

function GameModeOverlay:isAreaHovered(rect)
    local mx, my = love.mouse.getPosition()

    mx = mx / sx
    my = my / sy

    return mx >= rect.x
       and mx <= rect.x + rect.w
       and my >= rect.y
       and my <= rect.y + rect.h
end

function GameModeOverlay:onClicked()
    self.isSelected = true

    self.timer:after(self.timeToHide, function() self:hide() end)
end


function GameModeOverlay:hide()
    self.showing = false
    local pickedMode = (self.x < gw / 2) and GameModes.ATTACK or GameModes.DEFENSE
    self.onPicked(pickedMode)
end

function GameModeOverlay:draw()
    if not self.showing then return end

    love.graphics.setColor(unpack(self.backgroundColor))
    draft:rectangle(gw / 2, gh / 2, gw, gh, 'fill')

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        sprites.shopPanel, 
        gw / 2, gh / 2,
        0, 
        1, 1, 
        sprites.shopPanel:getWidth() / 2, 
        sprites.shopPanel:getHeight() / 2
    )

    love.graphics.setColor(unpack(colors.red))
    draft:rectangle(gw / 2 - self.w / 2, gh / 2, self.w, self.h, 'fill')
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.attackFont)
    printInsideRect('Score Points', self.attackFont, 'top', 50, self.attackRect)

    love.graphics.setColor(unpack(colors.blue))
    draft:rectangle(gw / 2 + self.w / 2, gh / 2, self.w, self.h, 'fill')
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.defendFont)
    printInsideRect('Defend', self.defendFont, 'top', 50, self.defendRect)

    love.graphics.setColor(1, 1, 1, 1)

    if not self.isSelected then self:drawConfirmButton() end

    love.graphics.draw(sprites.hand1, self.x, self.y, - math.pi * 0.5, 1, 1, sprites.hand1:getWidth() / 2, sprites.hand1:getHeight() / 2)

end

function GameModeOverlay:drawConfirmButton()
    local buttonRect = {x = self.buttonData.x, y = self.buttonData.y , w = self.buttonData.w, h = self.buttonData.h}
    local buttonCenter = getCenter(buttonRect)
    local buttonColor = (self.isHovered) and self.buttonData.hoveredColor or self.buttonData.color

    love.graphics.setColor(unpack(buttonColor))
    draft:rectangle(buttonCenter.x, buttonCenter.y , self.buttonData.w, self.buttonData.h, 'fill')

    love.graphics.setColor(unpack(self.buttonData.textColor))
    love.graphics.setFont(self.buttonFont)
    printInsideRect(self.buttonData.text, self.buttonFont, 'center', 0, buttonRect)
    
    love.graphics.setColor(1, 1, 1, 1)
end


function GameModeOverlay:die()
    self.dead = true
end

function GameModeOverlay:destroy()
   GameModeOverlay.super.destroy(self)
end

return GameModeOverlay