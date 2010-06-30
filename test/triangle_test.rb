require File.join(File.dirname(__FILE__), 'test_helper')

class TriangleTest < Test::Unit::TestCase
  def test_three_sides
    assert_triangle({ :a => "5.00", :b => "5.00", :c => "5.00" }, {}, {}, { :a => "60.00", :b => "60.00", :c => "60.00" })
  end
  
  def test_two_sides_and_complimentary_angle
    assert_triangle({ :a => "7.00", :b => "7.00" }, { :b => "60.00" }, { :c => "7.00" }, { :a => "60.00", :c => "60.00" })
  end
  
  def test_two_sides_and_other_angle
    assert_triangle({ :a => "3.00", :b => "4.00" }, { :c => "90.00" }, { :c => "5.00" }, { :a => "36.87", :b => "53.13" })
  end
  
  def test_two_angles_and_complimentary_side
    assert_triangle({ :a => "25.00" }, { :a => "60.00", :c => "60.00" }, { :b => "25.00", :c => "25.00" }, { :b => "60.00" })
  end
  
  def test_two_angles_and_other_side
    assert_triangle({ :a => "6.00" }, { :b => "60.00", :c => "60.00" }, { :b => "6.00", :c => "6.00" }, { :a => "60.00" })
  end
  
  def test_ambiguous_case
    alt = assert_triangle({ :a => "7.77", :c => "9.60" }, { :a => "50.50" }, { :b => "8.45" }, { :b => "57.07", :c => "72.43" }).alt.humanize
    assert_equal "3.76",   alt.side(:b)
    assert_equal "21.93",  alt.angle(:b)
    assert_equal "107.57", alt.angle(:c)
  end
  
  def test_area
    t = CosSinCalc::Triangle.new({ :a => 3.0, :b => 4.0, :c => 5.0 }, {})
    
    assert_equal 6.0,    t.area
    assert_equal "6.00", t.humanize.area
  end
  
  def test_circumference
    t = CosSinCalc::Triangle.new({ :a => 3.0, :b => 4.0, :c => 5.0 }, {})
    
    assert_equal 12.0,    t.circumference
    assert_equal "12.00", t.humanize.circumference
  end
  
  def test_altitudes
    t = CosSinCalc::Triangle.new({ :a => 3.0, :b => 4.0, :c => 5.0 }, {})
    
    assert_equal "4.00", t.humanize.altitude(:a)
    assert_equal "3.00", t.humanize.altitude(:b)
    assert_equal "2.40", t.humanize.altitude(:c)
  end
  
  def test_medians
    t = CosSinCalc::Triangle.new({ :a => 3.0, :b => 4.0, :c => 5.0 }, {})
    
    assert_equal "4.27", t.humanize.median(:a)
    assert_equal "3.61", t.humanize.median(:b)
    assert_equal "2.50", t.humanize.median(:c)
  end
  
  def test_angle_bisectors
    t = CosSinCalc::Triangle.new({ :a => 3.0, :b => 4.0, :c => 5.0 }, {})
    
    assert_equal "4.22", t.humanize.angle_bisector(:a)
    assert_equal "3.35", t.humanize.angle_bisector(:b)
    assert_equal "2.42", t.humanize.angle_bisector(:c)
  end
  
  def test_rounding
    t = CosSinCalc::Triangle.new({ :a => 3.2345 }, {})
    assert_equal 3.2345,  t.side(:a)
    assert_equal "3.23",  t.humanize.side(:a)
    assert_equal "3.235", t.humanize(3).side(:a)
  end
  
  def test_angle_conversion
    t1 = CosSinCalc::Triangle.new({}, { :a => "90.00", :unit => :degree })
    assert_in_delta (Math::PI/2), t1.angle(:a), 0.00001
    assert_equal "90.00",         t1.humanize.angle(:a)
    
    t2 = CosSinCalc::Triangle.new({}, { :a => "100.00", :unit => :gon })
    assert_in_delta (Math::PI/2), t2.angle(:a), 0.00001
    assert_equal "100.00",        t2.humanize.angle(:a)
    
    t3 = CosSinCalc::Triangle.new({}, { :a => (Math::PI/2).to_s, :unit => :radian })
    assert_in_delta (Math::PI/2), t3.angle(:a), 0.00001
    assert_equal "1.57",          t3.humanize.angle(:a)
  end
  
  def test_default_angle_unit
    t = CosSinCalc::Triangle.new({ :a => "5.00", :b => "5.00" }, { :c => "60.00" })
    assert_equal :degree, t.angles.unit
  end
  
  def test_number_parsing
    t = CosSinCalc::Triangle.new({ :a => "1 000.123 456", :b => "2.500,45", :c => "31,200.50" }, {})
    assert_equal 1000.123456, t.side(:a)
    assert_equal 2500.45,     t.side(:b)
    assert_equal 31200.50,    t.side(:c)
  end
  
  def test_one_side_and_angle
    t = CosSinCalc::Triangle.new({ :a => 3.0 }, { :c => "90", :unit => :degree })
    validation = t.calculate!
    
    assert_instance_of CosSinCalc::Triangle::Validator::ValidationError, validation
    assert_equal CosSinCalc::Triangle::Validator::NOT_ENOUGH_VARIABLES, validation.messages.first
    assert_equal 1, validation.messages.length
  end
  
  def test_three_angles
    t = CosSinCalc::Triangle.new({}, { :a => "40", :b => "40", :c => "100", :unit => :degree })
    validation = t.calculate!
    
    assert_instance_of CosSinCalc::Triangle::Validator::ValidationError, validation
    assert_equal CosSinCalc::Triangle::Validator::NO_SIDES, validation.messages.first
    assert_equal 1, validation.messages.length
  end
  
  def test_two_sides_and_angles
    t = CosSinCalc::Triangle.new({ :a => 3.0, :b => 3.0 }, { :b => "60", :c => "60", :unit => :degree })
    validation = t.calculate!
    
    assert_instance_of CosSinCalc::Triangle::Validator::ValidationError, validation
    assert_equal CosSinCalc::Triangle::Validator::TOO_MANY_VARIABLES, validation.messages.first
    assert_equal 1, validation.messages.length
  end
  
  def test_invalid_variables
    t = CosSinCalc::Triangle.new({ :a => (0.0/0.0), :b => -5.0 }, { :c => "180", :unit => :degree })
    validation = t.calculate!
    
    assert_instance_of CosSinCalc::Triangle::Validator::ValidationError, validation
    assert validation.messages.include?(CosSinCalc::Triangle::Validator::INVALID_SIDE)
    assert validation.messages.include?(CosSinCalc::Triangle::Validator::INVALID_ANGLE)
    assert_equal 2, validation.messages.length
    assert !validation.sides_valid[:a]
    assert !validation.sides_valid[:b]
    assert !validation.angles_valid[:c]
  end
  
  def test_invalid_triangle
    t = CosSinCalc::Triangle.new({ :b => 10.0, :c => 5.0 }, { :c => "90", :unit => :degree })
    validation = t.calculate!
    
    assert_instance_of CosSinCalc::Triangle::Validator::ValidationError, validation
    assert_equal CosSinCalc::Triangle::Validator::INVALID_TRIANGLE, validation.messages.first
    assert_equal 1, validation.messages.length
  end
  
  private
  def assert_triangle(known_sides, known_angles, unknown_sides, unknown_angles)
    t = CosSinCalc::Triangle.new(known_sides, { :unit => :degree }.merge(known_angles))
    assert_equal true, t.calculate!
    h = t.humanize
    
    known_sides.merge(unknown_sides).each_pair   { |var, val| assert_equal val, h.side(var) }
    known_angles.merge(unknown_angles).each_pair { |var, val| assert_equal val, h.angle(var) }
    
    t
  end
end
