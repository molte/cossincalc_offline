module CosSinCalc
  class Triangle
    class Formatter
      UNIT_FACTORS = { :radian => Math::PI, :degree => 180.0, :gon => 200.0 }
      
      attr_reader :triangle, :precision # References to associated triangle object and data precision.
      
      def initialize(triangle, precision = 2)
        @triangle  = triangle
        @precision = precision
      end
      
      # Converts an input value to a number.
      def self.parse(value)
        return value if value.is_a? Float
        return nil if value.nil? || value.to_s !~ /\S/
        
        value = value.to_s.gsub(/[^\d.,]+/, '').split(/[^\d]+/)
        value.push('.' + value.pop) if value.length > 1
        value.join.to_f
      end
      
      # Converts an input angle value in some unit to a radian number.
      def self.parse_angle(value, from_unit)
        value.is_a?(Float) ? value : convert_angle(parse(value), from_unit)
      end
      
      # Converts the given value from the unit specified to radians.
      # If reverse is true, the value will be converted from radians to the specified unit.
      def self.convert_angle(value, unit, reverse = false)
        return nil if value.nil?
        
        factor = (Math::PI / UNIT_FACTORS[unit.to_sym])
        value * (reverse ? 1.0 / factor : factor)
      end
      
      # Returns the size of the angle to the given variable, rounded and converted to the prefered unit.
      def angle(v)
        format(Formatter.convert_angle(t.angle(v), t.angles.unit, true), @precision)
      end
      
      private
      # Shorthand-method referencing the associated triangle object.
      def t
        @triangle
      end
      
      # Rounds the value down to the specified amount of decimals.
      def round(value, decimals)
        multiplier = 10 ** decimals
        (value * multiplier).round.to_f / multiplier
      end
      
      # Formats the given value to improve human readability.
      def format(value, decimals)
        "%.#{decimals}f" % round(value, decimals)
      end
      
      # Returns the number of significant digits of the given value.
      def significant_digits(number)
        number.to_s.gsub(/^[0.]+/, '').length
      end
      
      def method_missing(name, *args)
        if [:side, :altitude, :median, :angle_bisector, :area, :circumference].include?(name)
          format(t.send(name, *args), @precision)
        else
          super(name, *args)
        end
      end
    end
  end
end
