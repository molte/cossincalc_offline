module CosSinCalc
  class Triangle
    include Calculator
    
    VARIABLES = [:a, :b, :c]
    
    attr_reader :alt # Reference to alternative triangle at ambiguous case.
    attr_reader :equations # Steps performed to calculate the result.
    
    # Initializes a triangle object with the given sides and angles and an optional reference to an alternative triangle.
    # 
    # The sides and angles may be given either as a VariableHash object or an ordinary hash.
    # The angle unit may be specified inside the given_angles hash (using the key :unit and value either :degree, :gon or :radian).
    # If no angle unit is given it defaults to :degree.
    # If a hash is used then value parsing and conversion will only occur if the values are provided as strings.
    # Float angle values are expected to be radians no matter the given angle unit.
    def initialize(given_sides, given_angles, alternative = nil)
      initialize_variables
      
      given_sides.each { |v, value| side[v] = Formatter.parse(value) }
      
      angles.unit = (given_angles.respond_to?(:unit) ? given_angles.unit : given_angles.delete(:unit)) || :degree
      given_angles.each { |v, value| angle[v] = Formatter.parse_angle(value, angles.unit) }
      
      @alt = alternative
    end
    
    # Calculates the unknown variables in the triangle.
    def calculate!
      Validator.new(self).validate
      calculate_variables
      Validator.new(self).validate_calculation
      @calculated = true
    rescue Errno::EDOM
      Validator::ValidationError.new([Validator::INVALID_TRIANGLE])
    rescue Validator::ValidationError => exception
      exception
    end
    
    def humanize(precision = 2)
      Formatter.new(self, precision)
    end
    
    def angle(v = nil)
      v.nil? ? @angles : @angles[v]
    end
    alias_method :angles, :angle
    
    def side(v = nil)
      v.nil? ? @sides : @sides[v]
    end
    alias_method :sides, :side
    
    # Returns the length of the line which starts at the corner and is perpendicular with the opposite side.
    def altitude(v)
      require_calculation
      r = rest(v)
      Math.sin(angle(r[0])) * side(r[1])
    end
    
    # Returns the length of the line going from the corner to the middle of the opposite side.
    def median(v)
      require_calculation
      Math.sqrt((2 * sq(sides(rest(v))).inject(&:+) - sq(side(v))) / 4)
    end
    
    # Returns the length of the line between a corner and the opposite side which bisects the angle at the corner.
    def angle_bisector(v)
      require_calculation
      r = rest(v)
      Math.sin(angle(r[0])) * side(r[1]) / Math.sin(angle(r[1]) + angle(v) / 2)
    end
    
    # Returns the area of the triangle.
    def area
      require_calculation
      side(VARIABLES[0]) * side(VARIABLES[1]) * Math.sin(angle(VARIABLES[2])) / 2
    end
    
    # Returns the circumference of the triangle.
    def circumference
      require_calculation
      sides(VARIABLES).inject(&:+)
    end
    
    # Executes the given block for each variable symbol.
    # If an array of variable names is given, only those variables will be iterated through.
    def each(array = VARIABLES, &block)
      array.each { |v| block.arity == 2 ? yield(v, rest(v)) : yield(v) }
    end
    
    # Returns all the variable symbols except those given.
    def rest(*vars)
      VARIABLES - vars
    end
    
    # Returns whether the missing values have been successfully calculated.
    def calculated?
      @calculated
    end
    
    # Returns whether the given value is acute or not.
    def acute?(value)
      value < Math::PI / 2
    end
    
    # Returns whether the given value is obtuse or not.
    def obtuse?(value)
      value > Math::PI / 2
    end
    
    private
    # Reset the sides, angles etc. to their default values.
    def initialize_variables
      @sides  = VariableHash.new
      @angles = VariableHash.new
    end
    
    # Calculate the missing values of the triangle if not already done.
    def require_calculation
      calculate! unless calculated?
    end
  end
end
