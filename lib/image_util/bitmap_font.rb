# frozen_string_literal: true

module ImageUtil
  class BitmapFont
    def initialize(name)
      font = Image.from_file("#{__dir__}/bitmap_font/fonts/#{name}/font.png")
      charset = File.read("#{__dir__}/bitmap_font/fonts/#{name}/charset.txt").chomp.chars

      parse_image(font, charset)
    end

    def parse_image(font, charset)
      font.height.times do |n|
        if font[0,n] == :red
          @height = n
          break
        end
      end

      character_pos = []

      n = 0
      while n < font.width
        if font[n, @height] == :blue
          start = n
          n += 1 while n < font.width && font[n, @height] == :blue
          n -= 1
          finish = n
          character_pos << (start..finish)
        end
        n += 1
      end

      font = font.dup
      font.set_each_pixel_by_location! do |x,y|
        [255, 255, 255, 255 - font[x,y].g]
      end

      @characters = character_pos.map.with_index do |range,idx|
        [charset[idx], font[range, ...@height]]
      end.to_h
    end

    def render_line_of_text(text)
      width = 1
      text.chars.each do |char|
        width += @characters[char].width + 1
      end
      width -= 1

      img = Image.new(width, @height)
      width = 0
      text.chars.each do |char|
        img[width,0] = @characters[char]
        width += @characters[char].width + 1
      end

      img
    end

    def self.fonts
      Dir["#{__dir__}/bitmap_font/fonts/*"].map { |i| File.basename(i) }
    end

    def self.default_font = "smfont"

    def self.cached_load(font)
      @fonts ||= {}
      @fonts[font] ||= BitmapFont.new(font)
    end
  end
end
