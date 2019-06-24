gfx.LoadSkinFont("NotoSans-Regular.ttf");

-- Quick log.
Log = {
    i = function(text) game.Log(text, game.LOGGER_INFO) end,
    n = function(text) game.Log(text, game.LOGGER_NORMAL) end,
    w = function(text) game.Log(text, game.LOGGER_WARNING) end,
    e = function(text) game.Log(text, game.LOGGER_ERROR) end
}

-- Scaled graphics.
Sgfx = {
    scale_x = function(x, reverse)
        reverse = false or reverse
        local w, _ = game.GetResolution()
        if reverse then
            return x * (1 / (w / Sgfx.WIDTH))
        else
            return x * (w / Sgfx.WIDTH)
        end
    end,

    scale_y = function(y, reverse)
        reverse = false or reverse
        local _, h = game.GetResolution()
        if reverse then
            return y * (1 / (h / Sgfx.HEIGHT))
        else
            return y * (h / Sgfx.HEIGHT)
        end
    end,

    scale = function(x, y, reverse)
        reverse = false or reverse
        if reverse then
            return Sgfx.scale_x(x, true), Sgfx.scale_y(y, true)
        else
            return Sgfx.scale_x(x), Sgfx.scale_y(y)
        end
    end,

    WIDTH = 1080, HEIGHT = 1920,
    Resolution = function() return 1080, 1920 end,
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
    end
}