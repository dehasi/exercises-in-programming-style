require 'test/unit'

class Ch1Test < Test::Unit::TestCase

  WORK_DIR = "/Users/ravil/experimental/exips"

  def test_prints_top2
    system("ruby #{WORK_DIR}/lib/ch_02-go-forth.rb #{WORK_DIR}/text.txt > #{WORK_DIR}/answer")

    text = File.read("#{WORK_DIR}/answer")
    assert_true  text.include? 'banana-3'
    assert_true  text.include? 'kiwi-2'
    assert_true  text.include? 'apple-1'
    File.delete("#{WORK_DIR}/answer")
  end
end
