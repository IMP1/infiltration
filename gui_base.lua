local Widget = {}
Widget.__index = Widget

local SCROLL_THICKNESS = 6

function Widget.new(name, options)
    local this = {}
    this.name = name
    this.position         = options.position or { 0, 0 }
    this.size             = options.size     or { 64, 64 }
    this.content_position = { 0, 0 }
    this.content_size     = { unpack(this.size) }
    this.title            = options.title    or nil

    if this.title then
        this.content_position[2] = this.content_position[2] + 24
        this.content_size[2]     = this.content_size[2] - 24
    end

    return this
end

function Widget:getDimensions()
    local x, y = unpack(self.position)
    local w, h = unpack(self.size)
    return x, y, w, h
end

function Widget:getContentDimensions()
    local x, y = unpack(self.position)
    local ox, oy = unpack(self.content_position)
    local w, h = unpack(self.content_size)
    return x + ox, y + oy, w, h
end

function Widget:isMouseOver(mx, my)
    if mx == nil then
        mx, my = love.mouse.getPosition()
    end
    local x, y, w, h = self:getDimensions()
    return mx >= x and my >= y and mx <= x + w and my <= y + h
end

function Widget:createScrollBar(direction, row_size, rows, container_size)
    if not self.scroll then
        self.scroll = {}
    end
    
    local content_size = row_size * rows

    if content_size == 0 then
        self.scroll[direction] = { 
            0, 
            1,
            1,
        }
    else
        self.scroll[direction] = { 
            0, 
            container_size / (content_size + container_size), 
            math.floor(container_size / row_size) 
        }
    end

    if self.scroll[1] then
        self.content_size[2] = self.content_size[2] - SCROLL_THICKNESS
    end
    if self.scroll[2] then
        self.content_size[1] = self.content_size[1] - SCROLL_THICKNESS
    end
end

function Widget:moveScroll(dx, dy)
    if not self.scroll then return end

    local scroll = self.scroll[1]
    if scroll then
        scroll[1] = scroll[1] - dy * scroll[2] / scroll[3]
        if scroll[1] < 0 then
            scroll[1] = 0
        end
        if scroll[1] > 1 - scroll[2] then
            scroll[1] = 1 - scroll[2]
        end
    end
    local scroll = self.scroll[2]

    if scroll then
        scroll[1] = scroll[1] - dy * scroll[2] / scroll[3]
        if scroll[1] < 0 then
            scroll[1] = 0
        end
        if scroll[1] > 1 - scroll[2] then
            scroll[1] = 1 - scroll[2]
        end
    end
end

function Widget:scrollOffset()
    local w, h = unpack(self.size)
    local ox, oy = 0, 0
    if self.scroll then
        if self.scroll[1] then
            ox = self.scroll[1][1] / self.scroll[1][2] * w
        end
        if self.scroll[2] then
            oy = self.scroll[2][1] / self.scroll[2][2] * h
        end
    end
    return ox, oy
end

function Widget:keyPressed(key)
end

function Widget:keyReleased(key)
end

function Widget:keyTyped(text)
end

function Widget:mousePressed(mx, my, key)
end

function Widget:mouseReleased(mx, my, key)
end

function Widget:mouseScrolled(dx, dy)
end

function Widget:update(dt, mx, my)
end

function Widget:draw()
    self:drawShape(self:getDimensions())
    self:drawTitle(self:getDimensions())

    self:drawContents(self:getContentDimensions())
    self:drawScroll(self:getContentDimensions())
    self:drawTooltip()
end

function Widget:drawTitle(x, y, w, h)
    if not self.title then return end
    love.graphics.printf(self.title, x, y + 4, w, "center")
end

function Widget:drawShape(x, y, w, h)
    love.graphics.setColor(32, 32, 32)
    love.graphics.rectangle("fill", x, y, w, h)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", x, y, w, h)
end

function Widget:drawContents(x, y, w, h)
end

function Widget:drawScroll(x, y, w, h)
    if not self.scroll then return end
    love.graphics.setColor(255, 255, 255)
    if self.scroll[1] then
        love.graphics.rectangle("line", x, y + h, w, SCROLL_THICKNESS)
        local scroll_size = self.scroll[1][2] * w
        local scroll_offset = self.scroll[1][1] * w
        love.graphics.rectangle("fill", x + scroll_offset, y + h, scroll_size, SCROLL_THICKNESS)
    end
    if self.scroll[2] then
        love.graphics.rectangle("line", x + w, y, SCROLL_THICKNESS, h)
        local scroll_size = self.scroll[2][2] * h
        local scroll_offset = self.scroll[2][1] * h
        love.graphics.rectangle("fill", x + w, y + scroll_offset, SCROLL_THICKNESS, scroll_size)
    end
end

function Widget:drawTooltip()
    if not self.tooltip then return end
    local x, y = unpack(self.tooltip.position)
    local w = love.graphics.getFont():getWidth(self.tooltip.text)
    local h = love.graphics.getFont():getHeight()
    love.graphics.setColor(0, 0, 0)
    love.graphics.rectangle("fill", x - 2, y - 2, w + 4, h + 4)
    love.graphics.setColor(255, 255, 255)
    love.graphics.rectangle("line", x - 2, y - 2, w + 4, h + 4)
    love.graphics.print(self.tooltip.text, x, y)
end

return Widget