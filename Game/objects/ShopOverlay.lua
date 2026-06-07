local ShopOverlay = GameObject:extend()
local unpack = _G.unpack or table.unpack

function ShopOverlay:new(area, x, y, opts)
    ShopOverlay.super.new(self, area, x, y, opts)

    self.backgroundColor = {1.0, 0.0, 0.0, 0.5}
    self.panelColor = {0.0, 0.0, 0.8, 0.9} 

    self.w, self.h = gw * 0.75 , gh * 0.75

    self.showing = false

    self.onTransitionOut = nil

    -- x,y as top left
    self.buttonData = {
        x = gw / 2 - 132,
        y = 804 - 29,
        w = 264,
        h = 58,
        text = "OK",
        color = {1.0, 1.0, 1.0, 0.9},
        hoveredColor = {0.7, 0.7, 0.7, 0.9},
        textColor = {0.0, 0.0, 0.0, 1.0}
    }

    self.depth = 500

    self.isHovered = false
end

function ShopOverlay:show(callback)
    self.showing = true
    self.onTransitionOut = callback

    --TODO set items
end

function ShopOverlay:hide()
    self.showing = false

    -- TODO move callback to end of transition
    self.onTransitionOut()
end

function ShopOverlay:update(dt)
    ShopOverlay.super.update(self, dt)

    if not self.showing then return end

    local clicking = input:down('click') == true

    self.isHovered = self:isButtonHovered()

    if self.isHovered and clicking then
        self:hide()
    end

end 

function ShopOverlay:isButtonHovered()
    local mx, my = love.mouse.getPosition()

    mx = mx / sx
    my = my / sy

    return mx >= self.buttonData.x
       and mx <= self.buttonData.x + self.buttonData.w
       and my >= self.buttonData.y
       and my <= self.buttonData.y + self.buttonData.h
end

function ShopOverlay:draw()
    if not self.showing then return end

    local buttonRect = {x = self.buttonData.x, y = self.buttonData.y , w = self.buttonData.w, h = self.buttonData.h}

    local buttonCenter = getCenter(buttonRect)

    love.graphics.setColor(unpack(self.backgroundColor))
    draft:rectangle(gw / 2, gh / 2, gw, gh, 'fill')

    love.graphics.setColor(unpack(self.panelColor))
    draft:rectangle(gw / 2, gh / 2, self.w , self.h, 'fill')

    local buttonColor = (self.isHovered) and self.buttonData.hoveredColor or self.buttonData.color
    love.graphics.setColor(unpack(buttonColor))
    draft:rectangle(buttonCenter.x, buttonCenter.y , self.buttonData.w, self.buttonData.h, 'fill')

    love.graphics.setColor(unpack(self.buttonData.textColor))
    
    local demoFont = love.graphics.newFont(40)
    love.graphics.setFont(demoFont)
    printInsideRect(self.buttonData.text, demoFont, 'center', 0, buttonRect)
    
    love.graphics.setColor(1, 1, 1, 1)

end

function ShopOverlay:die()
    self.dead = true
end

function ShopOverlay:destroy()
   ShopOverlay.super.destroy(self)
end

return ShopOverlay