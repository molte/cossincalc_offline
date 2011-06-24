FILE_DIR  = File.dirname(__FILE__)
EXEC_PATH = File.expand_path File.join(FILE_DIR, '../bin/cossincalc')
TEMP_DIR  = File.join(Dir.pwd, '/tmp')

require File.join(FILE_DIR, 'test_helper')
require 'fileutils'

class CommandLineInterfaceTest < Test::Unit::TestCase
  def setup
    sleep 0.01 # Don't overload filesystem.
    Dir.mkdir(TEMP_DIR) unless File.directory?(TEMP_DIR)
  end
  
  def teardown
    FileUtils.remove_dir(TEMP_DIR, :force => true)
  end
  
  def test_default_directory
    assert_calculation "a=5 b=5 c=5", std_dir
  end
  
  def test_specific_directory
    dir = "test"
    assert_calculation "a=5 b=5 c=5 --directory #{dir}", dir
  end
  
  def test_directory_shorthand
    dir = "calc"
    assert_calculation "a=5 b=5 c=5 -o #{dir}", dir
  end
  
  def test_existing_directory
    dir = "test"
    Dir.mkdir File.join(TEMP_DIR, dir)
    assert_calculation "a=5 b=5 c=5 -o #{dir}", dir, :error => "Error: The specified directory already exists."
  end
  
  def test_force_directory_overwrite
    dir = "test"
    Dir.mkdir File.join(TEMP_DIR, dir)
    assert_calculation "a=5 b=5 c=5 -o #{dir} --force", dir
  end
  
  def test_simple_example
    assert_calculation "c=5 C=90 a=3", std_dir
  end
  
  def test_precision_example
    assert_calculation "-p 3 A=60 B=60 c=6.2", std_dir
  end
  
  def test_angle_unit_restriction
    assert_calculation "A=60 c=3 B=100 --degree --gon", std_dir, :error => "Error: Only one angle unit is allowed."
  end
  
  def test_calculation_errors
    assert_calculation "a=3 A=70", std_dir, :error => "Error: 3 values must be specified."
  end
  
  private
  def std_dir
    "cossincalc-calculation-#{Time.now.strftime('%Y-%m-%d')}"
  end
  
  def execute(cmd)
    Dir.chdir(TEMP_DIR) { `ruby #{EXEC_PATH} #{cmd} 2>&1` } # Redirect stderr to stdout.
  end
  
  def assert_calculation(cmd, dir, options = {})
    options[:files] ||= %w(result.svg result.png result.tex result.pdf)
    expected_output = options[:error] || options[:output] || "Success: The result can be found in #{dir}/result.pdf."
    
    assert_match Regexp.new(Regexp.escape(expected_output)), execute(cmd)
    
    unless options[:error]
      assert File.directory?(File.join(TEMP_DIR, dir)), "Directory doesn't exist: #{dir}."
      options[:files].each do |filename|
        assert File.file?(File.join(TEMP_DIR, dir, filename)), "File doesn't exist: #{filename}."
      end
    end
  end
end
