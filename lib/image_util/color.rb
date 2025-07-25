# frozen_string_literal: true

module ImageUtil
  class Color < Array
    def initialize(*args)
      super(args)
    end

    autoload :CSS_COLORS, "image_util/color/css_colors"
    def r = self[0]
    def g = self[1]
    def b = self[2]
    def a = self[3] || 255

    def r=(val); self[0] = val; end
    def g=(val); self[1] = val; end
    def b=(val); self[2] = val; end
    def a=(val); self[3] = val; end

    def self.component_from_number(number)
      case number
      when nil
        number
      when Integer
        number.clamp(0, 255)
      when Float
        (number * 255).clamp(0, 255)
      else
        raise ArgumentError, "wrong type passed as component (passed: #{number})"
      end
    end

    def self.from_buffer(buffer, color_bits)
      buffer.map do |i|
        case color_bits
        when 8
          i
        else
          i.to_f / 2**(color_bits - 8)
        end
      end.then { |val| new(*val) }
    end

    def to_buffer(color_bits, channels)
      map do |i|
        case color_bits
        when 8
          i
        else
          (i.to_f * 2**(color_bits - 8)).to_i
        end
      end + [255] * (channels - length)
    end

    # rubocop:disable Metrics/BlockNesting

    # Optimized shortpath for a heavily hit fragment. Let's skip creating colors if
    # they are to be output to buffer instantly.
    def self.from_any_to_buffer(value, color_bits, channels)
      if color_bits == 8
        case value
        when Color
          return value.to_buffer(color_bits, channels)
        when Array
          if channels == value.length && value.all?(Integer)
            return value
          elsif channels == 4 && value.length == 3 && value.all?(Integer)
            return value + [255]
          end
        when Symbol, String
          s = value.to_sym
          if CSS_COLORS.key?(s)
            if channels == 3
              return CSS_COLORS[s]
            elsif channels == 4
              return CSS_COLORS_4C[s]
            end
          end
        end
      end
      from(value).to_buffer(color_bits, channels)
    end

    # rubocop:enable Metrics/BlockNesting

    def self.from(value)
      case value
      when Color
        value
      when Array
        value.map do |i|
          component_from_number(i)
        rescue ArgumentError
          raise ArgumentError, "wrong type passed as array index (passed: #{value.inspect})"
        end.then { |val| new(*val) }
      when String
        case value
        when /\A#(\h)(\h)(\h)\z/
          new($1.to_i(16) * 0x11, $2.to_i(16) * 0x11, $3.to_i(16) * 0x11)
        when /\A#(\h{2})(\h{2})(\h{2})\z/
          new($1.to_i(16), $2.to_i(16), $3.to_i(16))
        when /\A#(\h{2})(\h{2})(\h{2})(\h{2})\z/
          new($1.to_i(16), $2.to_i(16), $3.to_i(16), $4.to_i(16))
        else
          if (rgb = CSS_COLORS[value.downcase.to_sym])
            new(*rgb)
          else
            raise ArgumentError, "wrong String passed as color (passed: #{value.inspect})"
          end
        end
      when Symbol
        if (rgb = CSS_COLORS[value])
          new(*rgb)
        else
          from(value.to_s)
        end
      when Integer, Float, NilClass
        new(*[component_from_number(value)] * 3)
      else
        raise ArgumentError, "wrong type passed as color (passed: #{value.inspect})"
      end
    end

    def self.[](*value)
      value = value.first if value.is_a?(Array) && value.length == 1
      from(value)
    end

    def inspect
      if a != 255
        "#%02x%02x%02x%02x" % [r, g, b, a]
      else
        "#%02x%02x%02x" % [r, g, b]
      end
    end

    def pretty_print(q)
      q.text inspect
    end

    def ==(other)
      other = begin
        Color.from(other)
      rescue StandardError
        nil
      end
      return false unless other.is_a?(Color)

      self_rgb  = self[0, 3]
      other_rgb = other[0, 3]
      return false unless self_rgb == other_rgb

      (self[3] || 255) == (other[3] || 255)
    end

    alias eql? ==

    # Overlays another color on top of this one taking the alpha
    # channel of both colors into account.
    def +(other)
      other = Color.from(other)

      base_a = a.to_f / 255
      over_a = other.a.to_f / 255

      out_a = over_a + base_a * (1 - over_a)

      return Color.new(0, 0, 0, 0) if out_a.zero?

      out_r = (other.r * over_a + r * base_a * (1 - over_a)) / out_a
      out_g = (other.g * over_a + g * base_a * (1 - over_a)) / out_a
      out_b = (other.b * over_a + b * base_a * (1 - over_a)) / out_a

      Color.new(out_r, out_g, out_b, out_a * 255)
    end

    # Multiplies the alpha channel by the given factor and returns a new color.
    def *(other)
      raise TypeError, "factor must be numeric" unless other.is_a?(Numeric)

      Color.new(r, g, b, (a * other).clamp(0, 255))
    end
  end
end
