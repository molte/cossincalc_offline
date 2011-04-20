module CosSinCalc
  class Triangle
    class VariableHash < Hash
      attr_accessor :unit
      
      # Initializes the variables.
      def initialize
        super()
        CosSinCalc::Triangle::VARIABLES.each { |v| self[v] = nil }
      end
      
      # If a symbol is given, returns the associated value.
      # If an array of symbols is given, returns an array of the associated values.
      def [](vars)
        vars.is_a?(Array) ? vars.map { |v| super(v) } : super(vars)
      end
      
      # Returns the amount of variables that have a value.
      def amount
        self.values.compact.size
      end
      
      # Returns an array of variables whose values are known.
      def known(vars = CosSinCalc::Triangle::VARIABLES)
        vars.reject { |v| !self[v] }
      end
      
      # Returns an array of variables whose values are unknown.
      def unknown(vars = CosSinCalc::Triangle::VARIABLES)
        vars.reject { |v| self[v] }
      end
    end
  end
end
