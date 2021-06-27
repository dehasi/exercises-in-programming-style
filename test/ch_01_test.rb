require 'test/unit'
# require 'ch_01'

class Ch1Test < Test::Unit::TestCase

  WORK_DIR = "/Users/ravil/experimental/exips"

  def test_calculates_count
    system("ruby #{WORK_DIR}/lib/ch_01.rb #{WORK_DIR}/text.txt > #{WORK_DIR}/answer")

    text = File.read("#{WORK_DIR}/word_freqs")
    assert_true  text.include? 'apple,0001'
    assert_true  text.include? 'banana,0003'
    assert_true  text.include? 'kiwi,0002'
  end

  def test_ignores_stop_words
    system("ruby #{WORK_DIR}/lib/ch_01.rb #{WORK_DIR}/text.txt > #{WORK_DIR}/answer")

    text = File.read("#{WORK_DIR}/word_freqs")
    assert_false  text.include? ' an'
    assert_false  text.include? ' the'
    assert_false  text.include? ' or'
    assert_false  text.include? ' z'
  end

  def test_prints_top
    system("ruby #{WORK_DIR}/lib/ch_01.rb #{WORK_DIR}/text.txt > #{WORK_DIR}/answer")

    text = File.read("#{WORK_DIR}/answer")
    assert_true  text.include? 'banana-3'
    assert_true  text.include? 'kiwi-2'
    assert_true  text.include? 'apple-1'
  end

  def teardown
    File.delete("#{WORK_DIR}/word_freqs")
    File.delete("#{WORK_DIR}/answer")
  end
end
