gfx.LoadSkinFont("NotoSans-Regular.ttf");

-- Quick log.
Qlog = {
    i = function(text) game.Log(text, game.LOGGER_INFO) end,
    n = function(text) game.Log(text, game.LOGGER_NORMAL) end,
    w = function(text) game.Log(text, game.LOGGER_WARNING) end,
    e = function(text) game.Log(text, game.LOGGER_ERROR) end
}

-- Scaled graphics.
Sgfx = {
    WIDTH = 1080, HEIGHT = 1920,
    Resolution = function() return 1080, 1920 end,
    Rect = function(x, y, w, h) return gfx.Rect(scalex(x), scaley(y), scalex(w), scaley(h)) end,
    ImageRect = function(x, y, w, h, img, alpha, angle) return gfx.ImageRect(scalex(x), scaley(y), scalex(w), scaley(h), img, alpha, angle) end,
    Text = function(s, x, y) return gfx.Text(s, scalex(x), scaley(y)) end,
    FastText = function(s, x, y) return gfx.FastText(s, scalex(x), scaley(y)) end,
    DrawLabel = function(l, x, y) return gfx.DrawLabel(l, scalex(x), scaley(y)) end,
    MoveTo = function(x, y) return gfx.MoveTo(scalex(x), scaley(y)) end,
    LineTo = function(x, y) return gfx.LineTo(scalex(x), scaley(y)) end,
    Circle = function(cx, cy, r) return gfx.Circle(scalex(cx), scaley(cy), scalex(r)) end,
    LabelSize = function(l)
        local w, h = gfx.LabelSize(l)
        return rscalex(w), rscaley(h)
    end
}

-- Utility.
Util = {
    draw_debug = function()
        local realx, realy = game.GetResolution()
        gfx.BeginPath()
        gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_BOTTOM)
        gfx.FontSize(15)
        Sgfx.FastText(realx .. "x" .. realy, Sgfx.WIDTH, Sgfx.HEIGHT)
        gfx.FillColor(255, 255, 255)
        gfx.Fill()
    end
}

scalex = function(i)
    local x, y = game.GetResolution()
    return i * (x / 1080)
end

rscalex = function(i)
    local x, y = game.GetResolution()
    return i * (1 / (x / 1080))
end

scaley = function(i)
    local x, y = game.GetResolution()
    return i * (y / 1920)
end

rscaley = function(i)
    local x, y = game.GetResolution()
    return i * (1 / (y / 1920))
end

mouse_intersects_scaled = function(x, y, w, h)
    local mposx, mposy = game.GetMousePos()
    mposx = rscalex(mposx) 
    mposy = rscaley(mposy)
    return mposx > x and mposy > y and mposx < x+w and mposy < y+h;
end