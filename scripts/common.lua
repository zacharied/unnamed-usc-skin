gfx.LoadSkinFont("NotoSans-Regular.ttf");

_unimplemented = function(funcname) Log.e("Call to unimplemented method `" .. funcname .. "`!") end

function point_is_in(px, py, x, y, w, h)
    return (px > x and px < x + w) and (py > y and py < y + h)
end

-- Shorthand for calling log functions.
Log = {
    info = function(text) game.Log(text, game.LOGGER_INFO) end,
    normal = function(text) game.Log(text, game.LOGGER_NORMAL) end,
    warning = function(text) game.Log(text, game.LOGGER_WARNING) end,
    error = function(text) game.Log(text, game.LOGGER_ERROR) end,
}

-- Scaled graphics.
Sgfx = {
    -- All scaling is performed with respect to a 1080x1920 screen.
    WIDTH = 1080, HEIGHT = 1920,

    scale_x = function(x, reverse)
        reverse = false or reverse
        local w, _ = game.GetResolution()
        return x * (reverse and (1 / (w / Sgfx.WIDTH)) or (w / Sgfx.WIDTH))
    end,

    scale_y = function(y, reverse)
        reverse = false or reverse
        local _, h = game.GetResolution()
        return y * (reverse and (1 / (h / Sgfx.HEIGHT)) or (h / Sgfx.HEIGHT))
    end,

    scale = function(x, y, reverse)
        reverse = false or reverse
        return Sgfx.scale_x(x, reverse), Sgfx.scale_y(y, reverse)
    end,

    Rect = function(x, y, w, h) return gfx.Rect(Sgfx.scale_x(x), Sgfx.scale_y(y), Sgfx.scale_x(w), Sgfx.scale_y(h)) end,
    ImageRect = function(x, y, w, h, img, alpha, angle) return gfx.ImageRect(Sgfx.scale_x(x), Sgfx.scale_y(y), Sgfx.scale_x(w), Sgfx.scale_y(h), img, alpha, angle) end,
    Text = function(s, x, y) return gfx.Text(s, Sgfx.scale_x(x), Sgfx.scale_y(y)) end,
    FastText = function(s, x, y) return gfx.FastText(s, Sgfx.scale_x(x), Sgfx.scale_y(y)) end,
    DrawLabel = function(l, x, y) return gfx.DrawLabel(l, Sgfx.scale_x(x), Sgfx.scale_y(y)) end,
    MoveTo = function(x, y) return gfx.MoveTo(Sgfx.scale_x(x), Sgfx.scale_y(y)) end,
    LineTo = function(x, y) return gfx.LineTo(Sgfx.scale_x(x), Sgfx.scale_y(y)) end,
    Circle = function(cx, cy, r) return gfx.Circle(Sgfx.scale_x(cx), Sgfx.scale_y(cy), Sgfx.scale_x(r)) end,
    LabelSize = function(l)
        local w, h = gfx.LabelSize(l)
        return Sgfx.scale_x(w, true), Sgfx.scale_y(h, true)
    end,

    -- Not a native gfx method, but here for convenience.
    GetMousePos = function()
        mx, my = game.GetMousePos()
        return Sgfx.scale(mx, my, true)
    end
}

-- A Widget is a collection of data that can be drawn. New widgets can be created by extending this class.
-- The following methods MUST be implemented by the child widget:
--   * get_bounds
--   * draw
-- The following methods MAY be implemented by the child widget:
--   * get_pos
--   * check_mouse
-- The remainder of the methods should not be modified.
Widget = {
    MOUSE_CHECK = false,
    action = nil,
    x = 0, y = 0, 

    new = function(self, o)
        o = o or {}
        setmetatable(o, self)
        self.__index = self
        return o
    end,

    -- Check if the mouse is inside the widget's bounding box.
    check_mouse = function(self)
        local mx, my = Sgfx.GetMousePos()
        local x, y = self:get_pos()
        local w, h = self:get_bounds()
        return point_is_in(mx, my, x, y, w, h)
    end,

    draw = function(self)
        _unimplemented("draw")
    end,

    with_pos = function(self, o)
        self.x = o.x or self.x
        self.y = o.y or self.y
        return self
    end,

    with_action = function(self, action)
        self.MOUSE_CHECK = true
        self.action = action
        return self
    end,

    -- Get the top-left coordinate of the widget's bounding box.
    get_pos = function(self)
        return self.x, self.y
    end,

    get_x = function(self)
        local x, _ = self:get_pos()
        return x 
    end,

    get_y = function(self)
        local _, y = self:get_pos()
        return y 
    end,

    -- Position below another widget.
    as_below = function(self, other, spacing)
        spacing = spacing or 0
        self.y = other:next_y() + spacing
        return self
    end,

    -- Position above another widget.
    as_above = function(self, other, spacing)
        spacing = spacing or 0
        self.y = other:get_y() - other:get_height() - spacing
        return self
    end,

    -- Position to the right of another widget.
    as_right_of = function(self, other, spacing)
        spacing = spacing or 0
        self.x = other:next_x() + spacing
        return self
    end,

    -- Position to left of another widget.
    as_left_of = function(self, other, spacing)
        spacing = spacing or 0
        self.x = other:get_x() - other:get_width() - spacing
        return self
    end,

    -- Get the dimensions of the widget's bounding box.
    get_bounds = function(self)
        _unimplemented("get_bounds")
        return 0, 0
    end,

    get_width = function(self)
        w, _ = self:get_bounds()
        return w
    end,

    get_height = function(self)
        _, h = self:get_bounds()
        return h
    end,

    -- Get the far x-side of the object.
    next_x = function(self)
        return self.x + self:get_width()
    end,

    -- Get the far y-side of the object.
    next_y = function(self)
        return self.y + self:get_height()
    end,
}

Image = Widget:new{
    width = 0, height = 0,
    image = nil,

    with_size = function(self, w, h)
        self.width = w
        self.height = h
        return self
    end,

    with_image = function(self, path)
        self.image = gfx.CreateImage(path, 0)
        return self
    end,

    -- !override
    get_bounds = function(self)
        return self.width, self.height
    end,

    -- !override
    draw = function(self)
        Sgfx.ImageRect(self.x, self.y, self.width, self.height, self.image, 1, 0)
    end,
}

-- Text on the screen.
TextLabel = Widget:new{ 
    label = nil, align = 0, font_size = 20,

    finish_with_text = function(self, text)
        self.label = gfx.CreateLabel(text, self.font_size, 0)
        return self
    end,

    with_font_size = function(self, size)
        self.font_size = size
        return self
    end, 

    with_align = function(self, align)
        self.align = align
        return self
    end,

    -- !override
    get_pos = function(self)
        local x
        if self.align & gfx.TEXT_ALIGN_LEFT ~= 0 then
            x = self.x
        elseif self.align & gfx.TEXT_ALIGN_RIGHT ~= 0 then
            x = self.x - self:get_width()
        elseif self.align & gfx.TEXT_ALIGN_CENTER ~= 0 then
            x = self.x - self:get_width() / 2
        else
            x = self.x
        end

        local y
        if self.align & gfx.TEXT_ALIGN_TOP ~= 0 then
            y = self.y
        elseif self.align & gfx.TEXT_ALIGN_BOTTOM ~= 0 then
            y = self.y - self:get_height()
        elseif self.align & gfx.TEXT_ALIGN_MIDDLE ~= 0 then
            y = self.y - self:get_height() / 2
        else
            y = self.y
        end
        
        return x, y
    end,

    -- !override
    get_bounds = function(self)
        return Sgfx.LabelSize(self.label)
    end,

    -- !override
    draw = function(self)
        gfx.TextAlign(self.align)
        Sgfx.DrawLabel(self.label, self.x, self.y)
    end
}