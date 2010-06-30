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
  
  def test_equation_variable_substitution
    triangle, latex = triangle_latex({ :a => "3", :c => "5" }, { :unit => :degree, :c => "90" })
    assert latex.include?('A=\arcsin\left(\frac{\sin(C) * a}{c}\right) &= \arcsin\left(\frac{\sin(90.00\degree) * 3.00}{5.00}\right)=36.87\degree')
    assert latex.include?('B=180\degree-A-C &= 180\degree-36.87\degree-90.00\degree=53.13\degree')
    assert latex.include?('b=\frac{\sin(B) * a}{\sin(A)} &= \frac{\sin(53.13\degree) * 3.00}{\sin(36.87\degree)}=4.00')
  end
  
  def test_drawing_embedment
    triangle, latex = triangle_latex({ :a => "5", :b => "5", :c => "5" }, { :unit => :degree })
    assert latex.include?('\usepackage{graphicx}')
    assert latex.include?('\includegraphics')
  end
  
  private
  def triangle_latex(sides, angles)
    triangle = CosSinCalc::Triangle.new(sides, angles)
    triangle.calculate!
    return triangle, CosSinCalc::Triangle::Formatter::Latex.new(triangle.humanize).to_tex
  end
end
