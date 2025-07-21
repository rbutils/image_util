# frozen_string_literal: true

module ImageUtil
  module Filter
    module Draw
      extend ImageUtil::Filter::Mixin

      # rubocop:disable Metrics/ParameterLists
      def draw_function!(
        color = Color[:black],
        limit = nil,
        axis:,
        draw_axis: nil,
        view: View::Interpolated,
        plane: [0,0]
      )
        fp = self.view(view)

        axis = axis_to_number(axis)
        draw_axis ||= case axis
                      when 0 then 1
                      when 1 then 0
                      end
        draw_axis = axis_to_number(draw_axis)

        limit ||= (0..)
        limit = Range.new(limit.begin, dimensions[axis]-1, false) if limit.end == nil

        limit.each do |axispoint|
          draw = yield(axispoint)

          loc = plane.dup
          loc[axis] = axispoint
          loc[draw_axis] = draw

          fp[*loc] = color
        end

        self
      end
      # rubocop:enable Metrics/ParameterLists

      def draw_line!(begin_loc, end_loc, color = Color[:black], view: View::Interpolated)
        begin_x, begin_y = begin_loc
        end_x, end_y = end_loc

        dist_x = (end_x - begin_x).abs
        dist_y = (end_y - begin_y).abs

        if dist_x < dist_y
          begin_x, end_x, begin_y, end_y = end_x, begin_x, end_y, begin_y if begin_y > end_y
          a = (end_x - begin_x).to_f / (end_y - begin_y)
          draw_function!(color, begin_y..end_y, axis: :y, view: view) do |y|
            begin_x + (y - begin_y) * a
          end
        else
          begin_x, end_x, begin_y, end_y = end_x, begin_x, end_y, begin_y if begin_x > end_x
          a = (end_y - begin_y).to_f / (end_x - begin_x)
          draw_function!(color, begin_x..end_x, axis: :x, view: view) do |x|
            begin_y + (x - begin_x) * a
          end
        end
      end

      def draw_circle!(center, radius, color = Color[:black], view: View::Interpolated)
        fp = self.view(view)
        cx, cy = center
        min_x = (cx - radius).ceil
        max_x = (cx + radius).floor
        min_x.upto(max_x) do |x|
          dy = Math.sqrt(radius * radius - (x - cx)**2)
          fp[x, cy + dy] = color
          fp[x, cy - dy] = color
        end

        min_y = (cy - radius).ceil
        max_y = (cy + radius).floor
        min_y.upto(max_y) do |y|
          dx = Math.sqrt(radius * radius - (y - cy)**2)
          fp[cx + dx, y] = color
          fp[cx - dx, y] = color
        end

        self
      end

      define_immutable_version :draw_function, :draw_line, :draw_circle

      private

      def axis_to_number(axis)
        axis = 0 if axis == :x
        axis = 1 if axis == :y
        axis = 2 if axis == :z
        axis
      end
    end
  end
end
