require 'test/unit'

class PrideAndPrejudiceTest < Test::Unit::TestCase

  ASCII_LOWERCASE_AND_SPACES = "abcdefghijklmnopqrstuvwxyz \n".chars
  WORK_DIR = "/Users/ravil/experimental/exips/nn"
  INPUT_PATH = "#{WORK_DIR}/test/pride-and-prejudice-input.txt"

  def text(filename)
    File.read("#{WORK_DIR}/test/#{filename}").strip.gsub("\r\n", "\n")
  end

  def out_path(style_path)
    style_path
      .gsub("/lib/", "/test/")
      .gsub(".rb", ".out")
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
      system("ruby #{script} #{INPUT_PATH} > #{out_path(script)}")
    end
    text(file_name(out_path(script_path)))
  end

  def ignore_test_ch35_returns_only_lowercase # runs 21 min
    actual_output = run_single_script("#{WORK_DIR}/lib/ch_35-dense-shallow-under-control.rb")

    actual_output.chars.each do |ch|
      assert(ASCII_LOWERCASE_AND_SPACES.include?(ch), "unexpected character = '#{ch}'")
    end
  end

  def teardown
    Dir["#{WORK_DIR}/test/*.out"].each do |file|
      File.delete(file)
    end
  end
end
