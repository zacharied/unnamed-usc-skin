WIN_X, WIN_Y = game.GetResolution()

MAIN_BUTTON_LINE_DIFF = 10
MAIN_BUTTON_VOFFSET = 100
MAIN_BUTTON_VSPACING = 20

COLOR_MAIN_BUTTON_INACTIVE = {180, 180, 180}
COLOR_MAIN_BUTTON_HOVER = {255, 255, 255}

ANIM_MAIN_BUTTON_LINE_RESIZE_TIME = 0.3

local time = 0

main_button_new = function(label_text)
    return {
        text = label_text,
        action = nil,
        label_inactive = nil,
        label_hover = nil,
        hover_start_moment = nil,
        hover_end_moment = nil,
    }
end

local main_buttons = {
    [1] = main_button_new("Start"),
    [2] = { text = "Settings" },
    [3] = { text = "Exit" }
}
local hovered_idx = nil

-- Calculate the rectangle of a main button given its index.
-- This assumes all main buttons are the same height.
function button_bounds(idx)
    width, height = gfx.LabelSize(main_buttons[idx].label_inactive)
    x = WIN_X / 2 - width / 2
    y = MAIN_BUTTON_VOFFSET + (height + MAIN_BUTTON_VSPACING) * idx
    return x, y, width, height
end

function anim_proportion(start, duration)
    if not start then return 1 end
    if time < duration then return 1 end
    return math.min(1, (time - start) / duration)
end

local init_done = false
-- Performs setup logic that can't be done at initial interpretation.
init = function()
    -- `Menu` isn't accessible at the start so we have to wait until the first `render`.
    main_buttons[1].action = Menu.Start
    main_buttons[2].action = Menu.Settings
    main_buttons[3].action = Menu.Exit

    for i, btn in ipairs(main_buttons) do
        game.Log("Creating label with text " .. btn.text, game.LOGGER_INFO)

        gfx.FillColor(table.unpack(COLOR_MAIN_BUTTON_INACTIVE))
        btn.label_inactive = gfx.CreateLabel(btn.text, 40, 0)

        gfx.FillColor(table.unpack(COLOR_MAIN_BUTTON_HOVER))
        btn.label_hover = gfx.CreateLabel(btn.text, 40, 0)

        x, y, width, height = button_bounds(i)
        game.Log("Button bounds: " .. x .. ", " .. y .. ", " .. width .. ", " .. height, game.LOGGER_INFO)
    end

    init_done = true
end

-- Check whether the mouse is within the rectangle.
mouse_intersects = function(x, y, w, h)
    mposx, mposy = game.GetMousePos()
    return mposx > x and mposy > y and mposx < x+w and mposy < y+h;
end

-- Draw a button centered horizontally.
draw_button = function(idx)
    btn = main_buttons[idx]
    x, y, width, height = button_bounds(idx)

    if mouse_intersects(x, y, width, height) then
        btn.hover_end_moment = nil
        if btn.hover_start_moment == nil then
            btn.hover_start_moment = time
        end

        gfx.FillColor(table.unpack(COLOR_MAIN_BUTTON_HOVER))
        gfx.DrawLabel(main_buttons[idx].label_hover, x, y)
        
        local anim = anim_proportion(btn.hover_start_moment, ANIM_MAIN_BUTTON_LINE_RESIZE_TIME)

        -- Draw box border.
        gfx.BeginPath()
        gfx.MoveTo(x + width / 2)
        gfx.LineTo(x + width / 2 + (width / 2) * min(1, )
        gfx.StrokeColor(table.unpack(COLOR_MAIN_BUTTON_HOVER))
        gfx.Stroke()
    else
        btn.hover_start_moment = nil
        if btn.hover_end_moment == nil then
            btn.hover_end_moment = time
        end

        local anim = anim_proportion(btn.hover_end_moment, ANIM_MAIN_BUTTON_LINE_RESIZE_TIME)

        gfx.FillColor(table.unpack(COLOR_MAIN_BUTTON_INACTIVE))
        gfx.DrawLabel(main_buttons[idx].label_inactive, x, y)

        gfx.BeginPath()
        gfx.MoveTo(x + MAIN_BUTTON_LINE_DIFF * anim, y + height)
        gfx.LineTo(x + width - MAIN_BUTTON_LINE_DIFF * anim, y + height)
        gfx.StrokeColor(table.unpack(COLOR_MAIN_BUTTON_INACTIVE))
        gfx.Stroke()
    end
end

-- Render the screen.
render = function(deltaTime)
    if not init_done then init() end

    hovered_idx = nil

    for i, btn in ipairs(main_buttons) do
        -- Draw buttons.
        draw_button(i)
    end

    time = time + deltaTime
end

-- Callback on mouse presses.
mouse_pressed = function(button)
    for i = 1, # main_buttons do
        local x, y, w, h = button_bounds(i)
        if mouse_intersects(x, y, w, h) then
            main_buttons[i].action()
            game.Log("Button " .. i .. " clicked.", game.LOGGER_INFO)
        end
    end
    return 0
end