#!/usr/bin/env ruby

# The classes

class TFExercise
  def info
    self.class.name.to_s
  end
end

# Models the contents of the file
class DataStorageManage < TFExercise

  def initialize(path_to_file)
    @data = File.read(path_to_file).downcase.gsub(/[\W_]+/, ' ')
  end

  # Returns the list words in storage
  def words
    @data.split
  end

  def info
    "#{super}: My major data storage is a #{@data.class.name}"
  end
end

# Models stop words filter
class StopWordManager < TFExercise

  def initialize
    @stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
    @stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  end

  def stop_word? (word)
    @stop_words.include? word
  end

  def info
    "#{super}: My major data storage is a #{@stop_words.class.name}"
  end
end

# Keeps the word frequency data
class WordFrequencyManager < TFExercise

  def initialize
    @word_freqs = Hash.new(0)
  end

  def increment_count(word)
    @word_freqs[word] += 1
  end

  def sorted
    @word_freqs.sort_by { |p| p[1] }.reverse
  end

  def info
    "#{super}: My major data storage is a #{@word_freqs.class.name}"
  end
end

class WordFrequencyController < TFExercise

  def initialize(path_to_file)
    @storage_manager = DataStorageManage.new(path_to_file)
    @stop_word_manager = StopWordManager.new
    @word_freq_manager = WordFrequencyManager.new
  end

  def run
    @storage_manager.words.each do |word|
      @word_freq_manager.increment_count word unless @stop_word_manager.stop_word? word
    end
    word_freqs = @word_freq_manager.sorted
    word_freqs.first(25).each do |tf|
      puts "#{tf[0]}-#{tf[1]}"
    end
  end
end

# The main function
WordFrequencyController.new(ARGV[0]).run