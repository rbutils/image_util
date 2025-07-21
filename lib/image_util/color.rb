# frozen_string_literal: true

module ImageUtil
  class Color < Array
    def initialize(*args)
      super(args)
    end

    CSS_COLORS = {
      "aliceblue" => [240, 248, 255],
      "antiquewhite" => [250, 235, 215],
      "aqua" => [0, 255, 255],
      "aquamarine" => [127, 255, 212],
      "azure" => [240, 255, 255],
      "beige" => [245, 245, 220],
      "bisque" => [255, 228, 196],
      "black" => [0, 0, 0],
      "blanchedalmond" => [255, 235, 205],
      "blue" => [0, 0, 255],
      "blueviolet" => [138, 43, 226],
      "brown" => [165, 42, 42],
      "burlywood" => [222, 184, 135],
      "cadetblue" => [95, 158, 160],
      "chartreuse" => [127, 255, 0],
      "chocolate" => [210, 105, 30],
      "coral" => [255, 127, 80],
      "cornflowerblue" => [100, 149, 237],
      "cornsilk" => [255, 248, 220],
      "crimson" => [220, 20, 60],
      "cyan" => [0, 255, 255],
      "darkblue" => [0, 0, 139],
      "darkcyan" => [0, 139, 139],
      "darkgoldenrod" => [184, 134, 11],
      "darkgray" => [169, 169, 169],
      "darkgrey" => [169, 169, 169],
      "darkgreen" => [0, 100, 0],
      "darkkhaki" => [189, 183, 107],
      "darkmagenta" => [139, 0, 139],
      "darkolivegreen" => [85, 107, 47],
      "darkorange" => [255, 140, 0],
      "darkorchid" => [153, 50, 204],
      "darkred" => [139, 0, 0],
      "darksalmon" => [233, 150, 122],
      "darkseagreen" => [143, 188, 143],
      "darkslateblue" => [72, 61, 139],
      "darkslategray" => [47, 79, 79],
      "darkslategrey" => [47, 79, 79],
      "darkturquoise" => [0, 206, 209],
      "darkviolet" => [148, 0, 211],
      "deeppink" => [255, 20, 147],
      "deepskyblue" => [0, 191, 255],
      "dimgray" => [105, 105, 105],
      "dimgrey" => [105, 105, 105],
      "dodgerblue" => [30, 144, 255],
      "firebrick" => [178, 34, 34],
      "floralwhite" => [255, 250, 240],
      "forestgreen" => [34, 139, 34],
      "fuchsia" => [255, 0, 255],
      "gainsboro" => [220, 220, 220],
      "ghostwhite" => [248, 248, 255],
      "gold" => [255, 215, 0],
      "goldenrod" => [218, 165, 32],
      "gray" => [128, 128, 128],
      "grey" => [128, 128, 128],
      "green" => [0, 128, 0],
      "greenyellow" => [173, 255, 47],
      "honeydew" => [240, 255, 240],
      "hotpink" => [255, 105, 180],
      "indianred" => [205, 92, 92],
      "indigo" => [75, 0, 130],
      "ivory" => [255, 255, 240],
      "khaki" => [240, 230, 140],
      "lavender" => [230, 230, 250],
      "lavenderblush" => [255, 240, 245],
      "lawngreen" => [124, 252, 0],
      "lemonchiffon" => [255, 250, 205],
      "lightblue" => [173, 216, 230],
      "lightcoral" => [240, 128, 128],
      "lightcyan" => [224, 255, 255],
      "lightgoldenrodyellow" => [250, 250, 210],
      "lightgray" => [211, 211, 211],
      "lightgrey" => [211, 211, 211],
      "lightgreen" => [144, 238, 144],
      "lightpink" => [255, 182, 193],
      "lightsalmon" => [255, 160, 122],
      "lightseagreen" => [32, 178, 170],
      "lightskyblue" => [135, 206, 250],
      "lightslategray" => [119, 136, 153],
      "lightslategrey" => [119, 136, 153],
      "lightsteelblue" => [176, 196, 222],
      "lightyellow" => [255, 255, 224],
      "lime" => [0, 255, 0],
      "limegreen" => [50, 205, 50],
      "linen" => [250, 240, 230],
      "magenta" => [255, 0, 255],
      "maroon" => [128, 0, 0],
      "mediumaquamarine" => [102, 205, 170],
      "mediumblue" => [0, 0, 205],
      "mediumorchid" => [186, 85, 211],
      "mediumpurple" => [147, 112, 219],
      "mediumseagreen" => [60, 179, 113],
      "mediumslateblue" => [123, 104, 238],
      "mediumspringgreen" => [0, 250, 154],
      "mediumturquoise" => [72, 209, 204],
      "mediumvioletred" => [199, 21, 133],
      "midnightblue" => [25, 25, 112],
      "mintcream" => [245, 255, 250],
      "mistyrose" => [255, 228, 225],
      "moccasin" => [255, 228, 181],
      "navajowhite" => [255, 222, 173],
      "navy" => [0, 0, 128],
      "oldlace" => [253, 245, 230],
      "olive" => [128, 128, 0],
      "olivedrab" => [107, 142, 35],
      "orange" => [255, 165, 0],
      "orangered" => [255, 69, 0],
      "orchid" => [218, 112, 214],
      "palegoldenrod" => [238, 232, 170],
      "palegreen" => [152, 251, 152],
      "paleturquoise" => [175, 238, 238],
      "palevioletred" => [219, 112, 147],
      "papayawhip" => [255, 239, 213],
      "peachpuff" => [255, 218, 185],
      "peru" => [205, 133, 63],
      "pink" => [255, 192, 203],
      "plum" => [221, 160, 221],
      "powderblue" => [176, 224, 230],
      "purple" => [128, 0, 128],
      "red" => [255, 0, 0],
      "rosybrown" => [188, 143, 143],
      "royalblue" => [65, 105, 225],
      "saddlebrown" => [139, 69, 19],
      "salmon" => [250, 128, 114],
      "sandybrown" => [244, 164, 96],
      "seagreen" => [46, 139, 87],
      "seashell" => [255, 245, 238],
      "sienna" => [160, 82, 45],
      "silver" => [192, 192, 192],
      "skyblue" => [135, 206, 235],
      "slateblue" => [106, 90, 205],
      "slategray" => [112, 128, 144],
      "slategrey" => [112, 128, 144],
      "snow" => [255, 250, 250],
      "springgreen" => [0, 255, 127],
      "steelblue" => [70, 130, 180],
      "tan" => [210, 180, 140],
      "teal" => [0, 128, 128],
      "thistle" => [216, 191, 216],
      "tomato" => [255, 99, 71],
      "turquoise" => [64, 224, 208],
      "violet" => [238, 130, 238],
      "wheat" => [245, 222, 179],
      "white" => [255, 255, 255],
      "whitesmoke" => [245, 245, 245],
      "yellow" => [255, 255, 0],
      "yellowgreen" => [154, 205, 50],
      "rebeccapurple" => [102, 51, 153]
    }.freeze
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
          new($1.to_i(16) * 0x11, $2.to_i(16) * 0x11, $3.to_i(16) * 0x11)
        when /\A#(\h{2})(\h{2})(\h{2})\z/
          new($1.to_i(16), $2.to_i(16), $3.to_i(16))
        when /\A#(\h{2})(\h{2})(\h{2})(\h{2})\z/
          new($1.to_i(16), $2.to_i(16), $3.to_i(16), $4.to_i(16))
        else
          if (rgb = CSS_COLORS[value.downcase])
            new(*rgb)
          else
            raise ArgumentError, "wrong String passed as color (passed: #{value.inspect})"
          end
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
