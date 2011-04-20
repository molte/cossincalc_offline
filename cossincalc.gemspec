require 'lib/cossincalc/version'

Gem::Specification.new do |s|
  s.name        = "cossincalc"
  s.version     = CosSinCalc::VERSION
  s.date        = Time.now.strftime('%Y-%m-%d')
  s.summary     = "Triangle calculator"
  s.homepage    = "http://cossincalc.com/"
  s.email       = "molte@cossincalc.com"
  s.author      = "Molte Emil Strange Andersen"
  s.files       = Dir[ "README.markdown", "MIT-LICENSE", "Rakefile", "lib/**/*", "bin/*" ]
  s.executables = [ "cossincalc" ]
  s.description = <<-EOT
CosSinCalc is a web application able to calculate the variables of a triangle. The live site is located at http://cossincalc.com/. This is an offline version of the calculator.

You can use the included command line utility to generate a PDF page containing all the results, formulae and a drawing of the triangle, or you can include it as a library in your Ruby application and use just the features you care about.
EOT
end
