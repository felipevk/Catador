local TimeTracker = GameObject:extend()

function TimeTracker:new(area, x, y, opts)
    TimeTracker.super.new(self, area, x, y, opts)
end

function TimeTracker:update(dt)
    TimeTracker.super.update(self, dt)
end 

function TimeTracker:draw()
end

function TimeTracker:destroy()
   TimeTracker.super.destroy(self)
end

return TimeTracker
