module ImageUtil
  class Color < Array
    def initialize(*args)
      super(args)
    end

    def r = self[0]
    def g = self[1]
    def b = self[2]
    def a = self[3] || 255

    def r=(val); self[0] = val; end
    def g=(val); self[1] = val; end
    def b=(val); self[2] = val; end
    def a=(val); self[3] = val; end

    def self.component_from_number(number)
      component = case number
      when nil
        number
      when Integer
        number.clamp(0,255)
      when Float
        (number*255).clamp(0,255)
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

    def to_buffer(color_bits, color_length)
      map do |i|
        case color_bits
        when 8
          i
        else
          (i.to_f * 2**(color_bits - 8)).to_i
        end
      end + [255] * (color_length - length)
    end

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
          new($1.to_i(16)*0x11, $2.to_i(16)*0x11, $3.to_i(16)*0x11)
        when /\A#(\h{2})(\h{2})(\h{2})\z/
          new($1.to_i(16), $2.to_i(16), $3.to_i(16))
        when /\A#(\h{2})(\h{2})(\h{2})(\h{2})\z/
          new($1.to_i(16), $2.to_i(16), $3.to_i(16), $4.to_i(16))
        when "black" then new(0, 0, 0)
        when "white" then new(255, 255, 255)
        when "red" then new(255, 0, 0)
        when "lime" then new(0, 255, 0)
        when "blue" then new(0, 0, 255)
        else
          raise ArgumentError, "wrong String passed as color (passed: #{value.inspect})"
        end
      when Symbol
        from(value.to_s)
      when Integer, Float, nil
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
        other = Color.from(other) rescue nil
        return false unless other.is_a?(Color)

        self_rgb  = self[0, 3]
        other_rgb = other[0, 3]
        return false unless self_rgb == other_rgb

        (self[3] || 255) == (other[3] || 255)
      end

    alias eql? ==
  end
end
