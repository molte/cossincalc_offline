require File.join(File.dirname(__FILE__), 'test_helper')

class LatexTest < Test::Unit::TestCase
  def test_ambiguous_case
    triangle, latex = triangle_latex({ :a => "7.77", :c => "9.60" }, { :unit => :degree, :a => "50.50" })
    assert_match /\\newpage/, latex
  end
  
  def test_no_ambiguous_case
    triangle, latex = triangle_latex({ :a => "5", :b => "5", :c => "5" }, {})
    assert_no_match /\\newpage/, latex
  end
  
  def test_variable_table
    triangle, latex = triangle_latex({ :a => "3", :b => "4" }, { :unit => :degree, :c => "90" })
    triangle.each do |v|
      assert latex.include?(triangle.humanize.side(v))
      assert latex.include?(triangle.humanize.angle(v))
      assert latex.include?(triangle.humanize.altitude(v))
      assert latex.include?(triangle.humanize.median(v))
      assert latex.include?(triangle.humanize.angle_bisector(v))
    end
  end
  
  private
  def triangle_latex(sides, angles)
    triangle = CosSinCalc::Triangle.new(sides, angles)
    triangle.calculate!
    return triangle, CosSinCalc::Triangle::Formatter::Latex.new(t.humanize).to_tex
  end
end
