local Pos = {
    TITLE_MARGIN_TOP = 100,
    TITLE_MARGIN_BOT = 200,
    BUTTON_VSPACING = 100
}

MenuAction = {
    to_game_action = function(action)
        if action == MenuAction.Start then
            return Menu.Start
        elseif action == MenuAction.Settings then
            return Menu.Settings
        elseif action == MenuAction.Exit then
            return Menu.Exit
        end
    end,

    Start = 1,
    Settings = 2,
    Exit = 3,
}

local widgets = {
    title = TextLabel:new()
                :with_align(gfx.TEXT_ALIGN_CENTER)
                :with_font_size(40)
                :finish_with_text("UUSCS"),

    btn1 = TextLabel:new()
                :with_action(MenuAction.Start)
                :with_align(gfx.TEXT_ALIGN_CENTER)
                :finish_with_text("Start"),
    
    btn2 = TextLabel:new()
                :with_action(MenuAction.Settings)
                :with_align(gfx.TEXT_ALIGN_CENTER)
                :finish_with_text("Settings"),
    
    btn3 = TextLabel:new()
                :with_action(MenuAction.Exit)
                :with_align(gfx.TEXT_ALIGN_CENTER)
                :finish_with_text("Exit"),
}

positioned = false
reposition = function()
    widgets.title.x = Sgfx.WIDTH / 2
    widgets.title.y = Pos.TITLE_MARGIN_TOP

    widgets.btn1.x = Sgfx.WIDTH / 2
    widgets.btn1.y = widgets.title:next_y() + Pos.TITLE_MARGIN_BOT

    widgets.btn2.x = Sgfx.WIDTH / 2
    widgets.btn2.y = widgets.btn1:next_y() + Pos.BUTTON_VSPACING

    widgets.btn3.x = Sgfx.WIDTH / 2
    widgets.btn3.y = widgets.btn2:next_y() + Pos.BUTTON_VSPACING
end

-- Render the screen.
render = function(deltaTime)
    if not positioned then
        reposition()
        positioned = true
    end

    for i, w in pairs(widgets) do
        gfx.BeginPath()
        w:draw()
        gfx.FillColor(255, 255, 255)
        gfx.Fill()
    end
end

-- Callback on mouse presses.
mouse_pressed = function(button)
    mx, my = game.GetMousePos()
    for i, w in pairs(widgets) do
        if w.MOUSE_CHECK and w:check_mouse() then
            MenuAction.to_game_action(w.action)()
        end
    end
    return 0
end