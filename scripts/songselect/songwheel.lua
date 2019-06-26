SongInfo = Widget:new{
    PADDING_V = 25,
    PADDING_H = 25,
    COVER_LABEL_SPACING = 25,
    LABEL_SPACING_V = 20,
    SCREEN_MARGIN_H = 20,
    LABEL_FONT_SIZE = 15,
    JACKET_SIZE = 250,

    widgets = {
        cover = nil,
        labels = {
        },

        data = nil,
    },

    with_song = function(self, song, difficulty)
        self.widgets.cover = Image:new()
                                :with_image(difficulty.jacketPath)
                                :with_size(self.JACKET_SIZE, self.JACKET_SIZE)
        self.widgets.data = {
            [1] = TextLabel:new()
                        :with_font_size(self.LABEL_FONT_SIZE)
                        :with_align(gfx.TEXT_ALIGN_RIGHT)
                        :finish_with_text(song.title),
            [2] = TextLabel:new()
                        :with_font_size(self.LABEL_FONT_SIZE)
                        :with_align(gfx.TEXT_ALIGN_RIGHT)
                        :finish_with_text(song.artist),
            [3] = TextLabel:new()
                        :with_font_size(self.LABEL_FONT_SIZE)
                        :with_align(gfx.TEXT_ALIGN_RIGHT)
                        :finish_with_text(difficulty.effector)
        }
        return self
    end,

    finish = function(self)
        self.widgets.labels = {
            [1] = TextLabel:new()
                        :with_font_size(self.LABEL_FONT_SIZE)
                        :finish_with_text("Title"),
            [2] = TextLabel:new()
                        :with_font_size(self.LABEL_FONT_SIZE)
                        :finish_with_text("Artist"),
            [3] = TextLabel:new()
                        :with_font_size(self.LABEL_FONT_SIZE)
                        :finish_with_text("Effector"),
        }
        return self
   end,

    positioned = false,
    reposition = function(self)
        self.widgets.cover.x = self.x + self.PADDING_H
        self.widgets.cover.y = self.y + self.PADDING_V

        -- Draw labels.
        for i, w in ipairs(self.widgets.labels) do
            w.x = self.widgets.cover:next_x() + self.COVER_LABEL_SPACING

            if i == 1 then
                w.y = self.y + self.PADDING_V
            else
                w.y = self.widgets.labels[i-1]:next_y() + self.LABEL_SPACING_V
            end
        end

        -- Draw data matching up with labels.
        for i, w in ipairs(self.widgets.data) do
            w.x = self:get_width() - self.PADDING_H

            if i == 1 then
                w.y = self.y + self.PADDING_V
            else
                w.y = self.widgets.labels[i-1]:next_y() + self.LABEL_SPACING_V
            end
        end
    end,

    -- !override
    get_bounds = function(self)
        return Sgfx.WIDTH - self.SCREEN_MARGIN_H * 2, self.JACKET_SIZE + self.PADDING_V
    end,

    -- !override
    draw = function(self)
        if not self.positioned then
            self:reposition()
            self.positioned = true
        end

        self.widgets.cover:draw()
        for _, w in pairs(self.widgets.labels) do
            w:draw()
        end
        for _, w in pairs(self.widgets.data) do
            w:draw()
        end
    end
}

set_diff = function()
    return 0
end

set_index = function()
    return 0
end

render = function(delta)
    si = SongInfo:new()
            :with_song(songwheel.songs[1], songwheel.songs[1].difficulties[1])
            :finish()
    si:draw()
end