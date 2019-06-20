-- Layout:
-- At the top of screen, songinfo showing jacket, diffs, artist, effector, etc.
-- Songinfo can be clicked on / a button pressed to expand and reveal scores and more metadata.
-- Below that is three rows of song jackets.
-- Below that is user info and button prompts.

-- Offset from bottom of song info to first row.
local ROWS_VOFFSET = 200
local ROWS_HOFFSET = 100
local ROWS_VSPACING = 100

local WHEEL_JACKET_SZ = 225
local WHEEL_HIGHLIGHT_GROW = 20

-- TEMP
local SONGINFO_HEIGHT = 350

-- The position on the grid that is highlighted. Should always be between 1 and 9.
local grid_idx = 1 
-- Index of currently highlighted song.
local selected_idx = 1
local diff_idx = 1

local jackets = {}

init = function()
    for i,song in ipairs(songwheel.songs) do
        Qlog.n("Loading jacket for song " .. song.id .. " at " .. song.difficulties[1].jacketPath)
        jackets[song.id] = gfx.CreateImage(song.difficulties[1].jacketPath, 0)
    end
    Qlog.n("Jackets: " .. #jackets)

    grid_idx = ((selected_idx - 1) % 3) + 1
end

-- Get the screen x coordinate of a jacket based on its horizontal position in the grid.
get_jacket_x = function(xcoord)
    local width, height = 1080, 1920
    local spacing = (width - ROWS_HOFFSET * 2 - WHEEL_JACKET_SZ * 3) / 2
    return ROWS_HOFFSET + (WHEEL_JACKET_SZ + spacing) * (xcoord - 1)
end

get_rows_yoffset = function()
    return SONGINFO_HEIGHT + ROWS_VOFFSET
end

SonginfoWidget = {
    HPADDING = 50,
    VPADDING = 50,
    JACKET_SZ = 275,
    LABEL_VSPACING = 18,
    DIFF_COUNT = 5,
    RADIUS_BOOST = 10,
    x = 20, y = 20,

    get_height = function(self)
        return self.JACKET_SZ + self.VPADDING * 2
    end
}

gfx.LoadSkinFont("NotoSans-BoldItalic.ttf")
SonginfoWidget.label_artist = gfx.CreateLabel("Artist", 20, 0)
SonginfoWidget.label_title = gfx.CreateLabel("Title", 20, 0)
SonginfoWidget.label_effector = gfx.CreateLabel("Effector", 20, 0)

function SonginfoWidget:draw()
    local song = songwheel.songs[selected_idx]

    -- Outline
    gfx.BeginPath()
    Sgfx.Rect(self.x, self.y, 1080 - self.x * 2, self.JACKET_SZ + self.VPADDING * 2)
    gfx.StrokeColor(127, 127, 127)
    gfx.Stroke()

    -- Jacket
    gfx.BeginPath()
    Sgfx.ImageRect(self.x + self.HPADDING, self.y + self.VPADDING, self.JACKET_SZ, self.JACKET_SZ, jackets[song.id], 1, 0)

    -- Labels
    gfx.BeginPath()
    gfx.TextAlign(gfx.TEXT_ALIGN_LEFT + gfx.TEXT_ALIGN_TOP)
    local x = self.x + self.HPADDING * 2 + self.JACKET_SZ
    local y_title = self.y + self.VPADDING
    Sgfx.DrawLabel(self.label_title, x, y_title)
    local labelw, labelh = Sgfx.LabelSize(self.label_title)
    local y_artist = y_title + labelh + self.LABEL_VSPACING
    Sgfx.DrawLabel(self.label_artist, x, y_artist)
    local y_effector = y_artist + labelh + self.LABEL_VSPACING
    Sgfx.DrawLabel(self.label_effector, x, y_effector)

    -- Metadata
    gfx.BeginPath()
    gfx.TextAlign(gfx.TEXT_ALIGN_RIGHT + gfx.TEXT_ALIGN_TOP)
    local meta_x = 1080 - self.x - self.HPADDING
    gfx.FontSize(20)
    Sgfx.Text(song.title, meta_x, y_title)
    Sgfx.Text(song.artist, meta_x, y_artist)
    Sgfx.Text(song.difficulties[1].effector, meta_x, y_effector) -- TODO Show correct effector

    --- Difficulties
    -- Difficulties are laid out in a 5x1 grid below the metadata.
    gfx.FontSize(25)
    local diff_v_space = self:get_height() - (y_effector + labelh - self.y)
    local diff_y = y_effector + labelh + diff_v_space / 2
    local diff_h_space = Sgfx.WIDTH - (self.x * 2 + self.JACKET_SZ + self.HPADDING * 3)
    local diff_start_x = self.x + self.JACKET_SZ + self.HPADDING + diff_h_space / self.DIFF_COUNT -- x of the first shown diff
    gfx.TextAlign(gfx.TEXT_ALIGN_CENTER + gfx.TEXT_ALIGN_MIDDLE)
    for i, diff in ipairs(song.difficulties) do
        Sgfx.Text(diff.level, diff_start_x + diff_h_space * ((i-1) / self.DIFF_COUNT), diff_y)
    end
    -- Highlight selected diff.
    gfx.BeginPath()
    local _, diff_text_ymin, _, diff_text_ymax = gfx.TextBounds(0, 0, "55") -- I'm guessing levels won't go this high...
    gfx.StrokeColor(255, 255, 255)
    Sgfx.Circle(diff_start_x + diff_h_space * ((diff_idx-1) / self.DIFF_COUNT), diff_y, diff_text_ymax - diff_text_ymin + self.RADIUS_BOOST)
    gfx.Stroke()
end

-- Draws grid centered horizontally on scren.
-- y: y-offset at which to draw grid.
draw_rows = function()
    -- Song index of the top-left jacket.
    local topleft_idx = selected_idx - grid_idx + 1
    for i = 1, 9 do
        if songwheel.songs[topleft_idx + i - 1] then
            --- Draw each jacket on the grid.
            local x = get_jacket_x(((i - 1) % 3) + 1)
            local y = get_rows_yoffset() + (WHEEL_JACKET_SZ + ROWS_VSPACING) * math.floor((i - 1) / 3)

            gfx.BeginPath()
            if not jackets[songwheel.songs[topleft_idx + i - 1].id] then
                -- TODO Use placeholder image.
                gfx.FillColor(255, 255, 255)
                Sgfx.Rect(x, y, WHEEL_JACKET_SZ, WHEEL_JACKET_SZ)
            else
                Sgfx.ImageRect(x, y, WHEEL_JACKET_SZ, WHEEL_JACKET_SZ, jackets[songwheel.songs[topleft_idx + i - 1].id], 1, 0)
            end
            gfx.Fill()

            gfx.BeginPath()
            gfx.FillColor(0, 0, 0)
            Sgfx.Text(topleft_idx + i - 1, x + 15, y + 20)
            gfx.Fill()
        end
    end
end

grid_coords = function()
    return ((grid_idx - 1) % 3) + 1, math.floor(grid_idx / 3) + 1
end

update_grid_idx = function(increment)
    if increment > 0 then
        if increment == 1 then
            grid_idx = grid_idx + 1
            if grid_idx > 9 then
                grid_idx = 7 + ((grid_idx - 10) % 3)
            end
        else
            for _i = increment, 1, -1 do
                update_grid_idx(1)
            end
        end
    elseif increment < 0 then
        if increment == -1 then
            grid_idx = grid_idx - 1
            if grid_idx < 1 then
                grid_idx = 3
            end
        else
            for _ = increment, -1, 1 do
                update_grid_idx(-1)
            end
        end
    end
end

-- Draw the outline for the currently selected song.
draw_highlight = function()
    gfx.BeginPath()
    gfx.StrokeColor(255, 255, 255)
    Sgfx.Rect(get_jacket_x(((grid_idx - 1) % 3) + 1) - WHEEL_HIGHLIGHT_GROW,
              get_rows_yoffset() + (WHEEL_JACKET_SZ + ROWS_VSPACING) * math.floor((grid_idx - 1) / 3) - WHEEL_HIGHLIGHT_GROW,
              WHEEL_JACKET_SZ + WHEEL_HIGHLIGHT_GROW * 2, WHEEL_JACKET_SZ + WHEEL_HIGHLIGHT_GROW * 2)
    gfx.Stroke()
end

set_index = function(new_idx)
    difference = new_idx - selected_idx
    selected_idx = new_idx
    update_grid_idx(difference)
end

set_diff = function(new_diff)
    diff_idx = new_diff
end

local needs_init = true
render = function(delta)
    if needs_init then
        init()
        needs_init = false
    end

    local select_row = math.floor(selected_idx / 3)

    SonginfoWidget:draw()
    draw_rows()
    draw_highlight()

    Util.draw_debug()
end