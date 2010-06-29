module CosSinCalc
  class Triangle
    class Validator
      NOT_ENOUGH_VARIABLES = '3 values must be specified.'
      TOO_MANY_VARIABLES   = 'Only 3 values should be specified.'
      NO_SIDES             = 'At least one side must be given.'
      INVALID_SIDE         = 'Only numbers (above zero) are accepted values for a side.'
      INVALID_ANGLE        = 'Only numbers (above zero) are accepted values for an angle. Furthermore the angle must remain inside the scope of the sum of all angles in the triangle.'
      INVALID_TRIANGLE     = 'The specified values do not match a valid triangle.'
      CALCULATOR_PRECISION = 0.01
      
      class ValidationError < Exception
        attr_reader :messages, :sides_valid, :angles_valid
        
        def initialize(messages, sides_valid = {}, angles_valid = {})
          @messages, @sides_valid, @angles_valid = messages, sides_valid, angles_valid
        end
      end
      
      def initialize(triangle)
        @triangle = triangle
      end
      
      # Validates the triangle before calculation and raises an exception on errors.
      def validate
        @sides_valid, @angles_valid = {}, {}
        
        t.each do |v|
          @sides_valid[v]  = t.side(v).nil?  || valid_side?(t.side(v))
          @angles_valid[v] = t.angle(v).nil? || valid_angle?(t.angle(v))
        end
        
        errors = error_messages
        errors.empty? || (raise ValidationError.new(errors, @sides_valid, @angles_valid))
      end
      
      # Checks whether the calculation was successful and the values given/calculated match a triangle.
      def validate_calculation
        t.each do |v, r|
          raise ValidtionError.new([INVALID_TRIANGLE]) unless valid_side?(t.side(v)) && valid_angle?(t.angle(v))
          
          angle = t.calculate_angle_by_sides(v, r)
          unless angle > t.angle(v) - CALCULATOR_PRECISION && angle < t.angle(v) + CALCULATOR_PRECISION
            raise ValidtionError.new([INVALID_TRIANGLE])
          end
        end
        return true
      end
      
      private
      # Shorthand-method referencing the associated triangle object.
      def t
        @triangle
      end
      
      # Returns an array of unique errors raised when validating the triangle.
      def error_messages
        errors = []
        errors << INVALID_SIDE  if @sides_valid.values.include?(false)
        errors << INVALID_ANGLE if @angles_valid.values.include?(false)
        
        if errors.empty?
          errors << NOT_ENOUGH_VARIABLES if total_values < 3
          errors << TOO_MANY_VARIABLES   if total_values > 3
          errors << NO_SIDES             if t.sides.amount < 1
        end
        
        return errors
      end
      
      # Returns the total number of variables given.
      def total_values
        @total_values ||= t.sides.amount + t.angles.amount
      end
      
      # Returns whether the value is a valid side.
      def valid_side?(value)
        value.is_a?(Float) && value.finite? && value > 0
      end
      
      # Returns whether the value is a valid angle.
      def valid_angle?(value)
        valid_side?(value) && value < Math::PI
      end
    end
  end
end
