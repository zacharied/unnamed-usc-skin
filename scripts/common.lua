gfx.LoadSkinFont("NotoSans-Regular.ttf");

-- Quick log.
Qlog = {
    i = function(text) game.Log(text, game.LOGGER_INFO) end,
    n = function(text) game.Log(text, game.LOGGER_NORMAL) end,
    w = function(text) game.Log(text, game.LOGGER_WARNING) end,
    e = function(text) game.Log(text, game.LOGGER_ERROR) end
}