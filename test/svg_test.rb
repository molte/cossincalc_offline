require File.join(File.dirname(__FILE__), 'test_helper')

class SvgTest < Test::Unit::TestCase
  def test_edge_label_declaration_positions
    triangle, svg = triangle_drawing({ :a => "5", :b => "5", :c => "5" }, {})
    assert_match /<text.+a =.+<\/text>\s*<text.+b =.+<\/text>\s*<text.+c =.+<\/text>\s*<\/svg>/, svg,
      "The edge labels should always be defined lastly due to the transformations and an ImageMagick rendering bug."
  end
  
  def test_precision_consistency
    triangle = CosSinCalc::Triangle.new({ :a => "5", :b => "5.00" }, { :a => "60", :unit => :degree })
    triangle.calculate!
    svg = CosSinCalc::Triangle::Drawing.new(triangle.humanize(3)).to_svg
    assert_equal 3, svg.scan(/60\.000&#176;/).length
    assert_equal 3, svg.scan(/[abc] = 5\.000/).length
  end
  
  def test_coordiantes
    triangle, svg = triangle_drawing({ :b => "5" }, { :unit => :degree, :a => "120", :c => "30" })
    assert_match /<polygon[^>]+points="(?:50\.0,261\.\d+\s?|550\.0,550\.0\s?|216\.\d+,550\.0\s?){3}"[^>]*\/>/, svg
    
    assert_match /<text[^>]+x="211\.\d+" y="564\.\d+"[^>]*>A/, svg
    assert_match /<text[^>]+x="42\.\d+" y="260\.\d+"[^>]*>B/, svg
    assert_match /<text[^>]+x="559\.\d+" y="558\.\d+"[^>]*>C/, svg
    
    assert_match /<path[^>]+d="M 241\.\d+,550\.0 A 25,25 0 0 0 204\.\d+,528\.\d+"/, svg
    assert_match /<path[^>]+d="M 62\.\d+,282\.\d+ A 25,25 0 0 0 71\.\d+,273\.\d+/, svg
    assert_match /<path[^>]+d="M 528\.\d+,537\.\d+ A 25,25 0 0 0 525\.0,550\.0"/, svg
    
    assert_match /<text[^>]+x="244\.\d+" y="508\.\d+"[^>]*>\d/, svg
    assert_match /<text[^>]+x="88\.\d+" y="306\.\d+"[^>]*>\d/, svg
    assert_match /<text[^>]+x="496\.\d+" y="541\.\d+"[^>]*>\d/, svg
    
    assert_match /transform="rotate\(30\.0 300\.0,405\.\d+\)"[^>]*>a/, svg
    assert_match /transform="rotate\(0\.0, 383\.\d+,550\.0\)"[^>]*>b/, svg
    assert_match /transform="rotate\(60\.0, 133\.\d+,405\.\d+\)"[^>]*>c/, svg
  end
  
  private
  def triangle_drawing(sides, angles)
    triangle = CosSinCalc::Triangle.new(sides, angles)
    triangle.calculate!
    return triangle, CosSinCalc::Triangle::Drawing.new(triangle.humanize).to_svg
  end
end
