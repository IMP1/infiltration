local Widget = require 'gui_base'

local Dropdown = {}
setmetatable(Dropdown, Widget)
Dropdown.__index = Dropdown

function Dropdown.new(options)
    local this = Widget.new("dropdown", options)
    setmetatable(this, Dropdown)

    this.placeholder   = options.placeholder   or nil
    this.initial_value = options.initial_value or nil
    this.item_height   = options.item_height   or 24
    this.options       = options.options       or {}
    this.closed_size   = options.closed_size   or { this.size[1], this.item_height }

    if options.populate then
        for option in options.populate() do
            table.insert(this.options, option)
        end
    end

    if this.item_height * #this.options > this.content_size[2] then
        this:createScrollBar(2, this.item_height, #this.options, this.content_size[2])
    end

    this.open = false
    return this
end

function Dropdown:drawContents(x, y, w, h)
    for i, option in pairs(self.options) do
        love.graphics.print(option.text, x, y + (i-1) * self.item_height)
    end
end

return Dropdown