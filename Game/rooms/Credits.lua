local Credits = Object:extend()
local unpack = _G.unpack or table.unpack

function Credits:new()
    self.area = Area(self)
    self.area:addPhysicsWorld()
    self.room_canvas = love.graphics.newCanvas(gw, gh)

    self.text =
    {
        { "Catador" },
        { "Pedro Kauati - Programmer" },
        { 
            "With Free use assets from",
            "1001fonts",
            "heritagetype",
            "rawpixel",
            "pdimagearchive",
            "freesound.org" 
        },
        {
            "Game Music",
            "Guifrog - Suco de Abacaxi"
        }
    }
end

function Credits:update(dt)
    -- this keeps the camera centered after shake
    camera.smoother = Camera.smooth.damped(5)
    camera:lockPosition(dt, gw/2, gh/2)
    
    self.area:update(dt)

    if input:pressed('click') then
        gotoRoom('Start')
    end
end

--[[
    Creates a canvas with the game resolution and resizes it to fit the scale
]]
function Credits:draw()
    love.graphics.setCanvas(self.room_canvas)
    love.graphics.clear()
    camera:attach(0, 0, gw, gh)
        self.area:draw()

        local yPos = 110

        -- TITLE
        local title = self.text[1][1]
        self:drawTextShadow(
            title, 
            fonts.vinqueAntiqueM, fonts.vinqueAntiqueL, 
            gw / 2 - (fonts.vinqueAntiqueM:getWidth(title) / 2), 
            yPos - (fonts.vinqueAntiqueM:getHeight()  / 2) ,
            gw / 2 - (fonts.vinqueAntiqueL:getWidth(title) / 2), 
            yPos - (fonts.vinqueAntiqueL:getHeight() / 2) 
        )        

        local creditsFont = fonts.anotherTypewritter
        yPos = 320

        for i = 2, #self.text do
            yPos = self:drawSection(self.text[i], yPos, 60, 60, creditsFont)
        end
        
        love.graphics.setColor(1, 1, 1, 1)

  	camera:detach()
    love.graphics.setCanvas()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setBlendMode('alpha', 'premultiplied')
    love.graphics.setShader(getMainShader())
    love.graphics.draw(self.room_canvas, 0, 0, 0, sx, sy)
    love.graphics.setShader()
    love.graphics.setBlendMode('alpha')
end

function Credits:drawSection(section, startY, padding, spacing, font)
    local y =  startY + padding
    local currentText = section[1]
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(font)

    love.graphics.print(currentText, gw / 2 - (font:getWidth(currentText) / 2), y - (font:getHeight()  / 2))

    if #section == 1 then 
        love.graphics.setColor(1, 1, 1, 1) 
        return y + padding
    end

    for i = 2, #section do
        y = y + spacing
        currentText = section[i]
        love.graphics.print(currentText, gw / 2 - (font:getWidth(currentText) / 2), y - (font:getHeight()  / 2))
    end

    love.graphics.setColor(1, 1, 1, 1)
    return y + padding
end

function Credits:drawTextShadow(text, fontBackground, fontForeground, x1, y1, x2, y2 )
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(fontBackground)
    love.graphics.print(text, x1, y1)
    
    love.graphics.setColor(0, 0, 0, 1)
    love.graphics.setFont(fontForeground)
    love.graphics.print(text, x2, y2)
    love.graphics.setColor(1, 1, 1, 1)
end

return Credits