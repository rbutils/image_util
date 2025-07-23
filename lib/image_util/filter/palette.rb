# frozen_string_literal: true

module ImageUtil
  module Filter
    module Palette
      extend ImageUtil::Filter::Mixin

      # A more descriptive name for this structure would be
      # N-tree, where N = 2**color_components. Let's pretend
      # we are dealing with 3-color component trees though,
      # so Octree it is.
      class ColorOctree < Array
        def dig(nexthop, *rest)
          self[nexthop] ||= ColorOctree.new(length)
          super
        end

        def number_bits(number)
          array = Array.new(8)
          i = 0
          number = number.to_i
          while i < 8
            array[7 - i] = ((number >> i) & 1)
            i += 1
          end
          array
        end

        def generate_key(component_bits)
          number = 0
          component_bits.reverse_each do |i|
            number <<= 1
            number |= i
          end
          number
        end

        def key_array(color)
          color.map do |component|
            number_bits(component)
          end.transpose.map do |i|
            generate_key(i)
          end
        end

        # rubocop:disable Style/Semicolon

        # Optimized path for (r,g,b) colors.
        def key_array3(color)
          i = 0
          r = color[0].to_i; g = color[1].to_i; b = color[2].to_i
          array = Array.new(8)
          while i < 8
            array[7 - i] = (r & 1) | (g & 1) << 1 | (b & 1) << 2
            r >>= 1; g >>= 1; b >>= 1
            i += 1
          end
          array
        end

        # Optimized path for (r,g,b,a) colors.
        def key_array4(color)
          i = 0
          r = color[0].to_i; g = color[1].to_i; b = color[2].to_i; a = color[3].to_i
          array = Array.new(8)
          while i < 8
            array[7 - i] = (r & 1) | (g & 1) << 1 | (b & 1) << 2 | (a & 1) << 3
            r >>= 1; g >>= 1; b >>= 1; a >>= 1
            i += 1
          end
          array
        end

        # rubocop:enable Style/Semicolon

        def build_from(colors)
          colors.each do |color|
            color_path = case color.length
                         when 3
                           key_array3(color)
                         when 4
                           key_array4(color)
                         else
                           key_array(color)
                         end

            dig(*color_path[0..-2])[color_path[-1]] = color
          end

          self
        end

        # rubocop:disable Style/StringConcatenation
        def inspect
          "#<Octree:[" +
            filter_map.with_index do |i,idx|
              "0b#{idx.to_s(2)} => #{i.inspect}," if i
            end.join(", ") +
            "]>"
        end
        # rubocop:enable Style/StringConcatenation

        def available_with_index
          each_with_index.select(&:first)
        end

        def pretty_print(pp)
          pp.group(1, "#<Octree:", ">") do
            pp.breakable ""
            pp.group(1, "[", "]") do
              pp.seplist(available_with_index) do |i,idx|
                pp.text "0b#{idx.to_s(2)}"
                pp.text " => "
                pp.pp i
              end
            end
          end
        end

        def empty?
          compact.empty?
        end

        def take(n)
          taken = []
          length.times do |idx|
            next unless (i = self[idx])

            taken << i
            self[idx] = nil

            if taken.length >= n - 1 && !empty?
              taken << self
              break
            elsif taken.length >= n
              break
            end
          end

          raise if taken.length > n

          taken
        end

        def colors
          select { |i| i.is_a? Color } +
            select { |i| i.is_a? ColorOctree }.map { |i| i.colors }.flatten(1)
        end
      end

      def palette_reduce!(count)
        colors = unique_colors

        return self if colors.length <= count

        octree = ColorOctree.new
        octree.build_from(colors)

        queue = [octree]
        while queue.length < count
          elem = queue.shift
          case elem
          when Color
            queue << elem
          when ColorOctree
            needed = count - queue.length
            got = elem.take(needed)
            queue += got
          end
        end

        equiv = {}

        queue.each do |i|
          case i
          when Color
            equiv[i] = i
          when ColorOctree
            colors = i.colors
            picked = colors[colors.length / 2]
            colors.each do |color|
              equiv[color] = picked
            end
          end
        end

        set_each_pixel_by_location do |loc|
          equiv[self[*loc]]
        end

        self
      end

      define_immutable_version :palette_reduce
    end
  end
end
