module CosSinCalc
  class Triangle
    module Calculator
      include Math
      
      def calculate_variables
        case sides.amount
        when 3 then calculate_three_angles
        when 2 then calculate_two_angles
        when 1 then calculate_two_sides
        end
      end
      
      # Calculates the last unknown angle and side.
      # This function is public so it is derectly callable (used with ambiguous case).
      def calculate_side_and_angle
        calculate_two_sides
      end
      
      # Calculates the value of an angle when all the sides are known.
      def calculate_angle_by_sides(v, r)
        acos (sq(sides(r)).inject(&:+) - sq(side(v))) / (2 * sides(r).inject(&:*))
      end
      
      # Add a calculation step to the list of equations performed.
      def equation(latex, *variables)
        @equations ||= []
        @equations << [latex, variables]
      end
      
      private
      def each(*args, &block)
        @triangle.each(*args, &block)
      end
      
      def sq(value)
        value.is_a?(Array) ? value.map { |n| n * n } : (value * value)
      end
      
      # Calculates all three angles when all three sides are known.
      def calculate_three_angles
        each do |v, r|
          unless angle(v)
            angle[v] = calculate_angle_by_sides(v, r)
            equation('@1=\arccos\left(\frac{$2^2+$3^2-$1^2}{2 * $2 * $3}\right)', v, *r)
          end
        end
      end
      
      # Calculates two unknown angles when two sides and one angle are known.
      def calculate_two_angles
        each do |v, r|
          if angle(v)
            unless side(v)
              side[v] = sqrt sq(sides(r)).inject(&:+) -
                2 * sides(r).inject(&:*) * cos(angle(v))
              equation('$1=\sqrt{$2^2+$3^2-2 * $2 * $3 * \cos(@1)}', v, *r)
              calculate_three_angles
              break
            end
            
            each(r) do |v2|
              if side(v2)
                angle[v2] = asin sin(angle(v)) * side(v2) / side(v)
                equation('@2=\arcsin\left(\frac{\sin(@1) * $2}{$1}\right)', v, v2)
                
                if ambiguous_case?(v, v2)
                  @alt = CosSinCalc::Triangle.new(sides, angles, self)
                  @alt.angle[v2] = PI - angle(v2)
                  @alt.equation('@2=@pi-\arcsin\left(\frac{\sin(@1) * $2}{$1}\right)', v, v2)
                  @alt.calculate_side_and_angle
                end
                
                calculate_two_sides
                break
              end
            end
            break
          end
        end
      end
      
      # Calculates up to two unknown sides when at least one side and two angles are known.
      def calculate_two_sides
        calculate_last_angle
        
        each do |v, r|
          if side(v)
            each(r) do |v2|
              unless side(v2)
                side[v2] = sin(angle(v2)) * side(v) / sin(angle(v))
                equation('$2=\frac{\sin(@2) * $1}{\sin(@1)}', v, v2)
              end
            end
            break
          end
        end
      end
      
      # Calculates the last unknown angle.
      def calculate_last_angle
        each do |v, r|
          unless angle(v)
            angle[v] = PI - angles(r).inject(&:+)
            equation('@1=@pi-@2-@3', v, *r)
            break
          end
        end
      end
      
      # Calculates and returns whether the triangle has multiple solutions.
      # See http://en.wikipedia.org/wiki/Law_of_sines#The_ambiguous_case
      def ambiguous_case?(v1, v2)
        acute?(angle(v1)) && side(v1) < side(v2) && side(v1) > side(v2) * sin(angle(v1))
      end
    end
  end
end
