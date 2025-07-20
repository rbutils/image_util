# frozen_string_literal: true

module ImageUtil
  class Image
    autoload :Buffer, "image_util/image/buffer"
    autoload :PixelView, "image_util/image/pixel_view"

    ALL = nil..nil

    def initialize(*dimensions, color_bits: 8, color_length: 4, &block)
      @buf = Buffer.new(dimensions, color_bits, color_length)

      set_each_pixel_by_location(&block) if block_given?
    end

    def initialize_from_buffer(buffer)
      @buf = buffer
    end

    def initialize_copy(_other)
      @buf = @buf.dup
    end

    def self.from_buffer(...)
      allocate.tap { |i| i.initialize_from_buffer(...) }
    end

    def buffer = @buf
    def dimensions = @buf.dimensions
    def width = dimensions[0]
    def height = dimensions[1]
    def length = dimensions[2]
    def color_bits = @buf.color_bits
    def color_length = @buf.color_length
    def pixel_bytes = @buf.pixel_bytes

    def location_expand(location)
      counts = []

      location = location.reverse.map.with_index do |i,idx|
        if i.is_a?(Range) && i.begin == nil
          i = Range.new(0, i.end, i.exclude_end?)
        end
        if i.is_a?(Range) && i.end == nil
          i = Range.new(i.begin, dimensions[-idx-1]-1, false)
        end

        i = i.to_i if i.is_a? Float

        i = Array(i)

        counts << i.count

        i
      end

      [counts.reverse, location.shift.product(*location).map(&:reverse)]
    end

    def check_bounds!(location)
      location.each_with_index do |i,idx|
        if i < 0 || i >= dimensions[idx]
          raise IndexError, "out of bounds image access (#{location.inspect} exceeds #{dimensions.inspect})"
        end
      end
    end

    def [](*location)
      if location.all?(Numeric)
        location = location.map(&:to_i)
        check_bounds!(location)
        @buf.get(location)
      else
        new_dimensions, locations = location_expand(location)
        new_image = Image.new(*new_dimensions, 
                              color_bits: color_bits,
                              color_length: color_length)

        locations.each_with_index do |i, idx|
          new_image.buffer.set_index(idx * @buf.pixel_bytes, @buf.get(i))
        end

        new_image
      end
    end

    def all=(value)
      self[*[ALL]*dimensions.length] = value
    end

    def []=(*location, value)
      if location.all?(Numeric)
        case value
        when Image
          last_dim = value.dimensions.length - 1
          value.each_with_index do |i, idx|
            new_location = location.dup
            new_location[last_dim] += idx
            self[*new_location] = i
          rescue IndexError
            # do nothing, image overlaps
          end
        else
          location = location.map(&:to_i)
          check_bounds!(location)
          @buf.set(location, value)
        end
      else
        _, locations = location_expand(location)
        locations.each do |loc|
          self[*loc] = value
        end
      end
    end

    def to_a
      if dimensions.length == 1
        dimensions.first.times.map { |i| self[i] }
      else
        @buf.last_dimension_split.map { |i| Image.from_buffer(i) }
      end
    end

    def deep_to_a
      to_a.map do |i|
        case i
        when Image
          i.deep_to_a
        else
          i
        end
      end
    end

    def each(...)
      to_a.each(...)
    end
    include Enumerable
    include Filter::Dither

    def length = dimensions.last

    def to_pam(fill_to: nil)
      if dimensions.length > 2
        raise ArgumentError, "can't convert to PAM more than 2 dimensions"
      end

      unless [3,4].include? color_length
        raise ArgumentError, "can't convert to PAM if color length isn't 3 or 4"
      end

      if fill_to
        remaining = (height || 1) % fill_to
        added = remaining > 0 ? fill_to - remaining : 0
        fill_height = (height || 1) + added
        fill_buffer = "\0".b * added * pixel_bytes * width
      else
        fill_height = height || 1
        fill_buffer = "".b
      end

      <<~PAM.b + @buf.get_string + fill_buffer
        P7
        WIDTH #{width}
        HEIGHT #{fill_height}
        DEPTH #{color_length}
        MAXVAL #{color_bits ** 2 - 1}
        TUPLTYPE #{color_length == 3 ? "RGB" : "RGB_ALPHA"}
        ENDHDR
      PAM
    end

    def to_sixel
      io = IO.popen("magick pam:- sixel:-", "r+")
      io << to_pam(fill_to: 6)
      io.close_write
      io.read
    end

    alias inspect to_sixel
    
    def pretty_print(p)
      Util.unlock_irb(p) do
        p.flush
        p.output << to_sixel
        p.text("", 0)
      end
    end

    def each_pixel_location(locations = [ALL]*dimensions.length, ...)
      location_expand(locations).last.each(...)
    end

    def each_pixel(locations = [ALL] * dimensions.length, &_block)
      each_pixel_location(locations) do |location|
        yield self[*location]
      end
    end

    def set_each_pixel_by_location(locations = [ALL] * dimensions.length, &_block)
      each_pixel_location(locations) do |location|
        value = yield location
        self[*location] = value if value
      end
    end
  end
end
