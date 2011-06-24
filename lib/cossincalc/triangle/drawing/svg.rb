module CosSinCalc
  class Triangle
    class Drawing
      module Svg
        VERTEX_LABEL_MARGIN = 10 # The distance between the middle of the vertex label and the vertex itself.
        VERTEX_VALUE_MARGIN = 55 # The distance between the middle of the vertex value and the vertex itself.
        FONT_SIZE           = 12 # The font size of the labels.
        ARC_RADIUS          = 25 # The radius of the circular arcs at the vertices.
        NEXT_VARIABLE       = { :a => :b, :b => :c, :c => :a } # The association between a variable and the next.
        
        # Returns a drawing of the triangle in SVG (Scalable Vector Graphics) format.
        def to_svg
          draw
          invert_coords
          
          polygon = @coords.values.map { |c| c.join(',') }.join(' ')
          labels  = ''
          
          t.each { |v| labels << vertex_label(v) << vertex_arc(v) << vertex_value(v) }
          t.each { |v| labels << edge_label(v) } # Needs to be drawn last in order to make ImageMagick render it correctly.
          
          <<-EOT
<?xml version="1.0" encoding="utf-8" standalone="no"?>
<svg xmlns="http://www.w3.org/2000/svg" version="1.1" width="#{canvas_size}" height="#{canvas_size}">
<polygon fill="#f5eae5" stroke="#993300" stroke-width="1" points="#{polygon}"/>
#{labels}</svg>
EOT
        end
        
        # Saves a drawing of the triangle as an PNG file.
        # The filename should be provided without the .png extension.
        def save_png(filename)
          save_svg(filename)
          Dir.cd_to(filename) do |basename|
            system("convert \"#{basename}.svg\" \"#{basename}.png\"") || system("rsvg-convert \"#{basename}.svg\" -o \"#{basename}.png\"")
          end
        end
        
        # Saves a drawing of the triangle as an SVG file.
        # The filename should be provided without the .svg extension.
        def save_svg(filename)
          File.open("#{filename}.svg", 'w') { |f| f.write(to_svg) }
        end
        
        private
        # Returns the SVG code for a label containing the given text at the given position.
        def label(x, y, text, attributes = nil)
          %[<text font-size="#{FONT_SIZE}" font-family="Verdana" fill="#333333" text-anchor="middle" x="#{x}" y="#{y + FONT_SIZE / 2}"#{' ' + attributes if attributes}>#{text}</text>\n]
        end
        
        # Returns the equivalent cartesian coordiantes (x and y) of the given polar coordiantes (angle and distance).
        def polar_to_cartesian(angle, distance)
          [ Math.cos(angle), Math.sin(angle) ].map { |val| distance * val }
        end
        
        # Returns the coordiantes of the vertex label of the given variable.
        def vertex_label_coords(v)
          x, y = *polar_to_cartesian(bisector_angle_to_x(v), VERTEX_LABEL_MARGIN)
          [ @coords[v][0] - x, @coords[v][1] + y ]
        end
        
        # Returns the SVG code for the vertex label of the given variable.
        def vertex_label(v)
          x, y = *vertex_label_coords(v)
          label(x, y, v.to_s.upcase)
        end
        
        # Returns the angle between the first edge (the right relative to the angle) connected to the given verted and the x-axis.
        def angle_to_x(v)
          case v
          when :a then 0.0
          when :b then -(t.angle(:b) + t.angle(:c))
          when :c then Math::PI - t.angle(:c)
          end
        end
        
        # Returns the angle between the angle bisector of the given vertex and the x-axis.
        def bisector_angle_to_x(v)
          t.angle(v) / 2 + angle_to_x(v)
        end
        
        # Returns the SVG code for the circular arcs at the given vertex.
        def vertex_arc(v)
          x1, y1 = *polar_to_cartesian(angle_to_x(v), ARC_RADIUS)
          x2, y2 = *polar_to_cartesian(angle_to_x(v) + t.angle(v), ARC_RADIUS)
          %[<path d="M #{@coords[v][0] + x1},#{@coords[v][1] - y1} A #{ARC_RADIUS},#{ARC_RADIUS} 0 0 0 #{@coords[v][0] + x2},#{@coords[v][1] - y2}" stroke="#90ee90" stroke-width="2" fill="none"/>\n]
        end
        
        # Returns the coordiantes of the vertex value label of the given variable.
        def vertex_value_coords(v)
          x, y = *polar_to_cartesian(bisector_angle_to_x(v), VERTEX_VALUE_MARGIN)
          [ @coords[v][0] + x, @coords[v][1] - y ]
        end
        
        # Returns the SVG code for the vertex label containing the value of the angle including the unit.
        def vertex_value(v)
          x, y = *vertex_value_coords(v)
          label(x, y, format_angle(f.angle(v), t.angles.unit))
        end
        
        # Adds the appropriate unit to the angle value.
        def format_angle(value, unit)
          if unit == :degree
            value + '&#176;'
          else
            value + ' gon'
          end
        end
        
        # Returns the SVG code for the given edge label.
        def edge_label(v)
          r = t.rest(v)
          x = (@coords[r[1]][0] - @coords[r[0]][0]) / 2 + @coords[r[0]][0]
          y = (@coords[r[1]][1] - @coords[r[0]][1]) / 2 + @coords[r[0]][1]
          
          v2    = NEXT_VARIABLE[v]
          angle = CosSinCalc::Triangle::Formatter.convert_angle(angle_to_x(v2) + t.angle(v2), :degree, true)
          text  = "#{v} = #{f.side(v)}"
          
          if angle < 90 && angle > -90
            label(x, y - FONT_SIZE, text, %[transform="rotate(#{-angle} #{x},#{y})"])
          else
            label(x, y + FONT_SIZE, text, %[transform="rotate(#{180 - angle}, #{x},#{y})"])
          end
        end
      end
    end
  end
end
