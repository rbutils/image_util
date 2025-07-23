# frozen_string_literal: true

module ImageUtil
  class Image
    autoload :Buffer, "image_util/image/buffer"
    autoload :PixelView, "image_util/image/pixel_view"

    Util.irb_fixup

    ALL = nil..nil

    def initialize(*dimensions, color_bits: 8, channels: 4, &block)
      @buf = Buffer.new(dimensions, color_bits, channels)

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

    def self.from_string(data, format = nil, codec: nil, **kwargs)
      format ||= Codec.detect(data)
      raise ArgumentError, "could not detect format" unless format

      Codec.decode(format, data, codec: codec, **kwargs)
    end

    def self.from_file(path_or_io, format = nil, codec: nil, **kwargs)
      if format
        if path_or_io.respond_to?(:read)
          path_or_io.binmode if path_or_io.respond_to?(:binmode)
          Codec.decode_io(format, path_or_io, codec: codec, **kwargs)
        else
          File.open(path_or_io, "rb") do |io|
            Codec.decode_io(format, io, codec: codec, **kwargs)
          end
        end
      elsif path_or_io.respond_to?(:read)
        path_or_io.binmode if path_or_io.respond_to?(:binmode)
        fmt, io = Magic.detect_io(path_or_io)
        raise ArgumentError, "could not detect format" unless fmt

        Codec.decode_io(fmt, io, codec: codec, **kwargs)
      else
        File.open(path_or_io, "rb") do |io|
          fmt, io = Magic.detect_io(io)
          raise ArgumentError, "could not detect format" unless fmt

          Codec.decode_io(fmt, io, codec: codec, **kwargs)
        end
      end
    end

    def buffer = @buf
    def dimensions = @buf.dimensions
    def width = dimensions[0]
    def height = dimensions[1]
    def length = dimensions[2]
    def color_bits = @buf.color_bits
    def channels = @buf.channels
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
                              channels: channels)

        locations.each_with_index do |i, idx|
          new_image.buffer.set_index(idx * @buf.pixel_bytes, @buf.get(i))
        end

        new_image
      end
    end

    def full_image_location = [ALL]*dimensions.length

    def all=(value)
      self[*full_image_location] = value
    end

    def []=(*location, value)
      if location.all?(Numeric)
        case value
        when Image
          paste!(value, *location)
        else
          location = location.map(&:to_i)
          check_bounds!(location)
          @buf.set(location, value)
        end
      else
        sizes, locations = location_expand(location)
        if value.is_a?(Image)
          paste!(value.resize(*sizes), *locations.first)
        else
          locations.each { |loc| self[*loc] = value }
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
    include Filter::Palette
    include Filter::Background
    include Filter::Paste
    include Filter::Draw
    include Filter::Resize
    include Filter::Transform
    include Statistic::Colors

    def length = dimensions.last

    def to_pam(fill_to: nil)
      Codec.encode(:pam, self, fill_to: fill_to)
    end

    def to_string(format, codec: nil, **kwargs)
      Codec.encode(format, self, codec: codec, **kwargs)
    end

    def to_file(path_or_io, format, codec: nil, **kwargs)
      if path_or_io.respond_to?(:write)
        path_or_io.binmode if path_or_io.respond_to?(:binmode)
        Codec.encode_io(format, self, path_or_io, codec: codec, **kwargs)
      else
        File.open(path_or_io, "wb") do |io|
          Codec.encode_io(format, self, io, codec: codec, **kwargs)
        end
      end
    end

    def to_sixel
      Codec.encode(:sixel, self)
    end

    def pretty_print(p)
      if (image = Terminal.output_image($stdin, $stdout, self))
        p.flush
        p.output << image
        p.text("", 0)
      else
        super
      end
    end

    def pixel_count(locations) = location_expand(locations).first.reduce(:*)

    def each_pixel_location(locations = full_image_location, ...)
      location_expand(locations).last.each(...)
    end

    def each_pixel(locations = full_image_location)
      return enum_for(:each_pixel) { pixel_count(locations) } unless block_given?

      each_pixel_location(locations) do |location|
        yield self[*location]
      end
    end

    def set_each_pixel_by_location(locations = full_image_location)
      return enum_for(:set_each_pixel_by_location) { pixel_count(locations) } unless block_given?

      each_pixel_location(locations) do |location|
        value = yield location
        self[*location] = value if value
      end
    end

    def view(obj)
      if block_given?
        yield obj.new(self)
        self
      else
        obj.new(self)
      end
    end
  end
end
