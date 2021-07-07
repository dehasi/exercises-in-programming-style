#!/usr/bin/env ruby

# Abstract things

# Models content of the file
class IDataStorage

  # Returns the words storage
  def words() end
end

# Models stop words filter
class IStopWordsFilter

  def stop_word?() end
end

class IWordFrequencyCounter

  def increment_count(word) end

  def sorted() end
end

class DataStorageManager < IDataStorage

  def initialize(path_to_file)
    @data = File.read(path_to_file).gsub(/[\W_]+/, ' ').downcase.split
  end

  def words
    @data
  end
end

class StopWordsManager < IStopWordsFilter

  def initialize
    @stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
    @stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  end

  def stop_word? (word)
    @stop_words.include? word
  end
end

class WordFrequencyManager < IWordFrequencyCounter

  def initialize
    @word_freqs = Hash.new(0)
  end

  def increment_count(word)
    @word_freqs[word] += 1
  end

  def sorted
    @word_freqs.sort_by { |p| p[1] }.reverse
  end
end

# The application object
class WordFrequencyController

  def initialize(path_to_file)
    @storage_manager = DataStorageManager.new(path_to_file)
    @stop_word_manager = StopWordsManager.new
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
