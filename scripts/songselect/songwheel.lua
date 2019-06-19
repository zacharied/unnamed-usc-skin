-- Layout:
-- At the top of screen, songinfo showing jacket, diffs, artist, effector, etc.
-- Songinfo can be clicked on / a button pressed to expand and reveal scores and more metadata.
-- Below that is three rows of song jackets.
-- Below that is user info and button prompts.

-- Offset from bottom of song info to first row.
local ROWS_VOFFSET = 200
local ROWS_HOFFSET = 100
local ROWS_VSPACING = 100

local WHEEL_JACKET_SZ = 150

-- TEMP
local SONGINFO_HEIGHT = 600

-- The position on the grid that is highlighted. Should always be between 1 and 9.
local grid_idx = 1 
-- Index of currently highlighted song.
local selected_idx = 1

local jackets = {}

init = function()
end

-- Get the screen x coordinate of a jacket based on its horizontal position in the grid.
get_jacket_x = function(xcoord)
    local width, height = game.GetResolution()
    local spacing = (width - ROWS_HOFFSET * 2 - WHEEL_JACKET_SZ * 3) / 2
    return ROWS_HOFFSET + (WHEEL_JACKET_SZ + spacing) * (xcoord - 1)
end

-- Draws grid centered horizontally on scren.
-- y: y-offset at which to draw grid.
draw_rows = function(y)
    -- Song index of the top-left jacket.
    local topleft_idx = selected_idx - grid_idx + 1
    for i = 1, 9 do
        --- Draw each jacket on the grid.
        gfx.BeginPath()
        gfx.FillColor(255 - (i - 1) * 30, 255, 255)
        gfx.Rect(get_jacket_x(((i - 1) % 3) + 1),
                 y + (WHEEL_JACKET_SZ + ROWS_VSPACING) * math.floor((i - 1) / 3),
                 WHEEL_JACKET_SZ, WHEEL_JACKET_SZ)
        gfx.Fill()
--        gfx.ImageRect(get_jacket_x((i - 1) % 3),
--                      y + (WHEEL_JACKET_SZ + ROWS_VSPACING) * (i - 1),
--                      WHEEL_JACKET_SZ, WHEEL_JACKET_SZ,
--                      jackets[topleft_idx + i - 1],
--                      255, 0)
    end
end

local needs_init = true
render = function(delta)
    if needs_init then
        --init()
        needs_init = false
    end
    local select_row = math.floor(selected_idx / 3)
    draw_rows(ROWS_VOFFSET)
end