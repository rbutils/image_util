# frozen_string_literal: true

# Silence a warning.
Warning[:experimental] = false

module ImageUtil
  class Image
    class Buffer
      def initialize(dimensions, color_bits, color_length, buffer = nil)
        @color_type = case color_bits
                      when 8
                        :U8
                      when 16
                        :u16
                      when 32
                        :u32
                      else
                        raise ArgumentError, "wrong color bits provided: #{color_bits.inspect}"
                      end

        @dimensions = dimensions.freeze
        @color_bits = color_bits
        @color_bytes = color_bits / 8
        @color_length = color_length

        @buffer_size = @dimensions.reduce(&:*)
        @buffer_size *= @color_length
        @buffer_size *= @color_bytes

        @io_buffer_types = ([@color_type]*@color_length).freeze

        @buffer = buffer || IO::Buffer.new(@buffer_size)

        apply_singleton_optimizations!

        freeze
      end

      attr_reader :dimensions, :color_bits, :color_bytes, :color_length

      def offset_of(*location)
        location.length == @dimensions.length or raise ArgumentError, "wrong number of dimensions"

        offset = 0
        location.reverse.zip(@dimensions.reverse) do |i,max|
          offset *= max
          offset += i
        end

        offset * pixel_bytes
      end

      def pixel_bytes = @color_length * @color_bytes

      def initialize_copy(_other)
        @buffer = @buffer.dup
      end

      def get(location)
        get_index(offset_of(*location))
      end

      def get_index(index)
        value = @buffer.get_values(@io_buffer_types, index)
        Color.from_buffer(value, @color_bits)
      end

      def set(location, value)
        set_index(offset_of(*location), value)
      end

      def set_index(index, value)
        value = Color.from(value).to_buffer(@color_bits, @color_length)
        @buffer.set_values(@io_buffer_types, index, value)
      end

      def last_dimension(i)
        dimensions_without_last = dimensions[0..-2]
        remaining_dimensions = dimensions_without_last.length
        o0 = offset_of(*[0] * remaining_dimensions, i)
        o1 = offset_of(*[0] * remaining_dimensions, i + 1)
        Buffer.new(
          dimensions_without_last,
          @color_bits,
          @color_length,
          @buffer.slice(o0, o1 - o0)
        )
      end

      def last_dimension_split
        dimensions.last.times.map do |i|
          last_dimension(i)
        end
      end

      def get_string = @buffer.get_string

      # Optimizations for most common usecases:
      def apply_singleton_optimizations!
        # rubocop:disable Style/GuardClause
        if OPT_OFFSET_OF.key?(@dimensions.length)
          singleton_class.define_method(:offset_of, &OPT_OFFSET_OF[@dimensions.length])
        end

        if OPT_GET_INDEX.key?(@color_bits)
          singleton_class.define_method(:get_index, &OPT_GET_INDEX[@color_bits])
        end
        # rubocop:enable Style/GuardClause
      end

      def width = dimensions[0]

      OPT_OFFSET_OF = {
        1 => ->(x) { x * pixel_bytes },
        2 => ->(x,y) { (y * width + x) * pixel_bytes }
      }.freeze

      OPT_GET_INDEX = {
        8 => ->(index) { Color.new(*@buffer.get_values(@io_buffer_types, index)) }
      }.freeze
    end
  end
end
