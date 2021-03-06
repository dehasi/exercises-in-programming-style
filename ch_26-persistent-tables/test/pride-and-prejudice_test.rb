require 'test/unit'

class PrideAndPrejudiceTest < Test::Unit::TestCase

  WORK_DIR = '/Users/ravil/experimental/exips/ch_26-persistent-tables'
  INPUT_PATH = "#{WORK_DIR}/test/pride-and-prejudice-input.txt"

  def text(filename)
    File.read("#{WORK_DIR}/test/#{filename}").strip.gsub("\r\n", "\n")
  end

  def out_path(style_path)
    style_path
      .gsub('/lib/', '/test/')
      .gsub('.rb', '.out')
  end

  def file_name(style_path)
    style_path.split('/')[-1]
  end

  def running_sandwich(style_path)
    puts "#{Time.new.inspect} Running #{file_name(style_path)}"
    yield(style_path)
    puts "#{Time.new.inspect} Finish #{file_name(style_path)}"
  end

  def run_single_script(script_path)
    running_sandwich(script_path) do |script|
      system("cd #{WORK_DIR} && rake ch26 > #{out_path(script)}")
    end

    expected_output = text('pride-and-prejudice-output.txt')
    actual_output = text(file_name(out_path(script_path)))
    assert_equal(expected_output, actual_output)
  end

  def test_single_style
    run_single_script("#{WORK_DIR}/lib/ch_26-persistent-tables.rb")
  end

  def teardown
    Dir["#{WORK_DIR}/test/*.out"].each do |file|
      File.delete(file)
    end
  end
end
