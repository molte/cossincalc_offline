module CosSinCalc
  class Triangle
    class Drawing
      include Svg
      
      # Initializes the drawing object of the given formatter's triangle with the provided maximum size and border padding.
      def initialize(formatter, size = 500, padding = 50)
        @formatter, @size, @padding = formatter, size, padding
        @triangle = @formatter.triangle
        @coords = {}
      end
      
      private
      # Calculates the coordinates of the verticies of the triangle and scales it to maximum allowed size.
      def draw
        calculate_coords
        resize
        apply_padding
      end
      
      # Shorthand-method referencing the associated triangle object.
      def t; @triangle end
      
      # Shorthand-method referencing the associated triangle formatter object.
      def f; @formatter end
      
      # Calculates the coordinates for the corners of the triangle.
      def calculate_coords
        @coords[:a] = [ 0, 0 ]
        @coords[:b] = [ t.side(:c) * Math.cos(t.angle(:a)), t.altitude(:b) ]
        @coords[:c] = [ t.side(:b), 0 ]
        
        if t.obtuse?(t.angle(:a))
          move_coords(-@coords[:b][0])
        end
      end
      
      # Moves the corners of the triangle with the given distance to the right.
      # Pass a negative value to move them to the left.
      def move_coords(distance)
        t.each { |v| @coords[v][0] += distance }
      end
      
      # Scales the coordiantes to fit the size of the canvas.
      def resize
        scale_coords @size / [@coords[:b][0], @coords[:c][0], @coords[:b][1]].max
      end
      
      # Scales the coordinates with the given amount.
      def scale_coords(scalar)
        t.each do |v|
          @coords[v][0] *= scalar
          @coords[v][1] *= scalar
        end
      end
      
      # Switches between bottom-left and top-left origin of the coordiante system.
      def invert_coords
        t.each { |v| @coords[v][1] = canvas_size - @coords[v][1] }
      end
      
      # Adds a padding around the triangle.
      def apply_padding
        t.each do |v|
          @coords[v][0] += @padding
          @coords[v][1] += @padding
        end
      end
      
      # Returns the total size of the canvas, ie. the sum of the size of the triangle and the padding on both sides of it.
      def canvas_size
        @size + @padding * 2
      end
    end
  end
end
