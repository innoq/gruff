require File.dirname(__FILE__) + '/base'

##
# Here's how to make a Pie graph:
#
#   g = Gruff::Pie.new
#   g.title = "Visual Pie Graph Test"
#   g.data 'Fries', 20
#   g.data 'Hamburgers', 50
#   g.write("test/output/pie_keynote.png")
#
# To control where the pie chart starts creating slices, use #zero_degree.

class Gruff::Pie < Gruff::Base

  DEFAULT_TEXT_OFFSET_PERCENTAGE = 0.15

  # Can be used to make the pie start cutting slices at the top (-90.0)
  # or at another angle. Default is 0.0, which starts at 3 o'clock.
  attr_writer :zero_degree

  # Do not show labels for slices that are less than this percent. Use 0 to always show all labels.
  # Defaults to 0
  attr_writer :hide_labels_less_than

  # Affect the distance between the percentages and the pie chart
  # Defaults to 0.15
  attr_writer :text_offset_percentage

  ## Use values instead of percentages
  attr_accessor :show_values_as_labels

  attr_accessor :absolute_label_value

  def initialize_ivars
    super
    @absolute_label_value = false
  end

  def zero_degree
    @zero_degree ||= 0.0
  end

  def hide_labels_less_than
    @hide_labels_less_than ||= 0.0
  end

  def text_offset_percentage
    @text_offset_percentage ||= DEFAULT_TEXT_OFFSET_PERCENTAGE
  end

  def options
    {
      :zero_degree            => zero_degree,
      :hide_labels_less_than  => hide_labels_less_than,
      :text_offset_percentage => text_offset_percentage,
      :show_values_as_labels  => show_values_as_labels
    }
>>>>>>> remotes/official/master
  end

  def draw
    hide_line_markers

    super

<<<<<<< HEAD
    return unless @has_data

    diameter = @graph_height
    radius = ([@graph_width, @graph_height].min / 2.0) * 0.8
    center_x = @graph_left + (@graph_width / 2.0)
    center_y = @graph_top + (@graph_height / 2.0) - 10 # Move graph up a bit
    total_sum = sums_for_pie()
    prev_degrees = @zero_degree

    # Use full data since we can easily calculate percentages
    data = (@sort ? @data.sort{ |a, b| a[DATA_VALUES_INDEX].first <=> b[DATA_VALUES_INDEX].first } : @data)
    data.each do |data_row|
      if data_row[DATA_VALUES_INDEX].first > 0
        @d = @d.stroke data_row[DATA_COLOR_INDEX]
        @d = @d.fill 'transparent'
        @d.stroke_width(radius) # stroke width should be equal to radius. we'll draw centered on (radius / 2)

        current_degrees = (data_row[DATA_VALUES_INDEX].first / total_sum) * 360.0 

        # ellipse will draw the the stroke centered on the first two parameters offset by the second two.
        # therefore, in order to draw a circle of the proper diameter we must center the stroke at
        # half the radius for both x and y
        @d = @d.ellipse(center_x, center_y, 
                  radius / 2.0, radius / 2.0,
                  prev_degrees, prev_degrees + current_degrees + 0.5) # <= +0.5 'fudge factor' gets rid of the ugly gaps
                  
        half_angle = prev_degrees + ((prev_degrees + current_degrees) - prev_degrees) / 2
        
        label_val = ((data_row[DATA_VALUES_INDEX].first / total_sum) * 100.0).round
        unless label_val < @hide_labels_less_than
          # RMagick must use sprintf with the string and % has special significance.
          if @absolute_label_value
            label_string = "#{data_row[0]}: #{data_row[DATA_VALUES_INDEX].first.to_s}"
          else
            label_string = label_val.to_s + '%'
          end

          @d = draw_label(center_x,center_y, half_angle,
                          radius + (radius * @text_offset_percentage),
                          label_string)
        end

        prev_degrees += current_degrees
=======
    return unless data_given?

    slices.each do |slice|
      if slice.value > 0
        set_stroke_color slice
        set_fill_color
        set_stroke_width
        set_drawing_points_for slice
        process_label_for slice
        update_chart_degrees_with slice.degrees
>>>>>>> remotes/official/master
      end
    end

    trigger_final_draw
  end

  private

  def slices
    @slices ||= begin
      slices = @data.map { |data| slice_class.new(data, options) }

      slices.sort_by(&:value) if @sort

      total = slices.map(&:value).inject(:+).to_f
      slices.each { |slice| slice.total = total }
    end
  end

  # General Helper Methods

  def hide_line_markers
    @hide_line_markers = true
  end

  def data_given?
    @has_data
  end

  def update_chart_degrees_with(degrees)
    @chart_degrees = chart_degrees + degrees
  end

  def slice_class
    PieSlice
  end

  # Spatial Value-Related Methods

  def chart_degrees
    @chart_degrees ||= zero_degree
  end

  def graph_height
    @graph_height
  end

  def graph_width
    @graph_width
  end

  def diameter
    graph_height
  end

  def half_width
    graph_width / 2.0
  end

  def half_height
    graph_height / 2.0
  end

  def radius
    @radius ||= ([graph_width, graph_height].min / 2.0) * 0.8
  end

  def center_x
    @center_x ||= @graph_left + half_width
  end

  def center_y
    @center_y ||= @graph_top + half_height - 10
  end

  def distance_from_center
    20.0
  end

  def radius_offset
    radius + (radius * text_offset_percentage) + distance_from_center
  end

  def ellipse_factor
    radius_offset * text_offset_percentage
  end

  # Label-Related Methods

  def process_label_for(slice)
    if slice.percentage >= hide_labels_less_than
      x, y  = label_coordinates_for slice

      @d = draw_label(x, y, slice.label)
    end
  end

  def label_coordinates_for(slice)
    angle = chart_degrees + slice.degrees / 2

    [x_label_coordinate(angle), y_label_coordinate(angle)]
  end

  def x_label_coordinate(angle)
    center_x + ((radius_offset + ellipse_factor) * Math.cos(deg2rad(angle)))
  end

  def y_label_coordinate(angle)
    center_y + (radius_offset * Math.sin(deg2rad(angle)))
  end

  # Drawing-Related Methods

  def set_stroke_width
    @d.stroke_width(radius)
  end

  def set_stroke_color(slice)
    @d = @d.stroke slice.color
  end

  def set_fill_color
    @d = @d.fill 'transparent'
  end

  def set_drawing_points_for(slice)
    @d = @d.ellipse(
      center_x,
      center_y,
      radius / 2.0,
      radius / 2.0,
      chart_degrees,
      chart_degrees + slice.degrees + 0.5
    )
  end

  def trigger_final_draw
    @d.draw(@base_image)
  end

  def configure_label_styling
    @d.fill        = @font_color
    @d.font        = @font if @font
    @d.pointsize   = scale_fontsize(@marker_font_size)
    @d.stroke      = 'transparent'
    @d.font_weight = BoldWeight
    @d.gravity     = CenterGravity
  end

  def draw_label(x, y, value)
    configure_label_styling

    @d.annotate_scaled(
      @base_image,
      0,
      0,
      x,
      y,
      value,
      @scale
    )
  end

  # Helper Classes

  class PieSlice < Struct.new(:data_array, :options)
    attr_accessor :total

    def name
      data_array[0]
    end

    def value
      data_array[1].first
    end

    def color
      data_array[2]
    end

    def size
      @size ||= value / total
    end

    def percentage
      @percentage ||= (size * 100.0).round
    end

    def degrees
      @degrees ||= size * 360.0
    end

    def label
      options[:show_values_as_labels] ? value.to_s : "#{percentage}%"
    end
  end
end
