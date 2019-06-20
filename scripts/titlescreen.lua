-- We use 1080p as our base measurement.
WIN_WIDTH, WIN_HEIGHT = game.GetResolution()

-- Logo is shown at top of screen.
local LOGO_TOP_OFFSET = 200

--- Main buttons are arranged vertically below the title logo.
-- Offset of first main button from logo.
local MAIN_BUTTON_VOFFSET = 100
-- Spacing between bottom of a main button and top of the next.
local MAIN_BUTTON_VSPACING = 20
local MAIN_BUTTON_FONT_SZ = 40

local COLOR_MAIN_BUTTON_INACTIVE = {180, 180, 180}
local COLOR_MAIN_BUTTON_HOVER = {255, 255, 255}

main_button_new = function(btn_text, btn_action)
    return {
        text = btn_text,
        action = btn_action,
        label = gfx.CreateLabel(btn_text, MAIN_BUTTON_FONT_SZ, 0)
    }
end

local main_buttons = {}
local logo_label = nil

-- Calculate the rectangle of a main button given its index.
-- This assumes all main buttons are the same height.
button_bounds = function(idx)
    local width, height = Sgfx.LabelSize(main_buttons[idx].label)
    local _, logo_height = Sgfx.LabelSize(logo_label)
    local x = Sgfx.WIDTH / 2 - width / 2
    local y = LOGO_TOP_OFFSET + logo_height + MAIN_BUTTON_VOFFSET + (height + MAIN_BUTTON_VSPACING) * idx
    return x, y, width, height
end

-- Performs setup logic that can't be done at initial interpretation.
init = function()
    main_buttons[1] = main_button_new("Start", Menu.Start)
    main_buttons[2] = main_button_new("Settings", Menu.Settings)
    main_buttons[3] = main_button_new("Exit", Menu.Exit)
end

-- Check whether the mouse is within the rectangle.
mouse_intersects = function(x, y, w, h)
    mposx, mposy = game.GetMousePos()
    return mposx > scalex(x) and mposy > scaley(y) and mposx < scalex(x+w) and mposy < scaley(y+h);
end

draw_logo = function()
    local LOGO_FONT_SZ = 70
    if not logo_label then
        logo_label = gfx.CreateLabel("UUSCS", LOGO_FONT_SZ, 0)
    end

    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
    width, height = gfx.LabelSize(logo_label)
    gfx.FillColor(255, 255, 255)
    Sgfx.DrawLabel(logo_label, Sgfx.WIDTH / 2, LOGO_TOP_OFFSET)
end

-- Draw a button centered horizontally.
draw_button = function(idx, btn)
    local x, y, width, height = button_bounds(idx)

    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT, gfx.TEXT_ALIGN_TOP)
    if mouse_intersects_scaled(x, y, width, height) then
        -- Hover state.
        gfx.FillColor(table.unpack(COLOR_MAIN_BUTTON_HOVER))
        Sgfx.DrawLabel(main_buttons[idx].label, x, y)

        gfx.BeginPath()
        Sgfx.MoveTo(x + 10, y + height)
        Sgfx.LineTo(x + width - 10, y + height)
        gfx.StrokeColor(table.unpack(COLOR_MAIN_BUTTON_HOVER))
        gfx.Stroke()
    else
        -- Inactive state.
        gfx.FillColor(table.unpack(COLOR_MAIN_BUTTON_INACTIVE))
        Sgfx.DrawLabel(main_buttons[idx].label, x, y)
    end
end

local needs_init = true
-- Render the screen.
render = function(deltaTime)
    if needs_init then 
        init() 
        needs_init = false
    end

    draw_logo()

    -- Draw buttons.
    for i, btn in ipairs(main_buttons) do
        draw_button(i, btn)
    end

    Util.draw_debug()
end

-- Callback on mouse presses.
mouse_pressed = function(button)
    for i = 1, # main_buttons do
        local x, y, w, h = button_bounds(i)
        if mouse_intersects_scaled(x, y, w, h) then
            main_buttons[i].action()
            Qlog.i("Button " .. i .. " clicked.")
            return 0
        end
    end
    return 0
end