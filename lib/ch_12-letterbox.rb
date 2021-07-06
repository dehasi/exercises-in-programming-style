#!/usr/bin/env ruby

# Models the content of the file
class DataStorageManager
  @data = ''

  def dispatch(message)
    case message[0]
    when 'init'
      init(message[1])
    when 'words'
      words
    else
      raise "Message is not understood #{message[0]}"
    end
  end

  def init(path_to_file)
    @data = File.read(path_to_file).gsub(/[\W_]+/, ' ').downcase
  end

  def words
    @data.split
  end
end

# Models stop word filter
class StopWordManager
  @stop_words = []

  def dispatch(message)
    case message[0]
    when 'init'
      init
    when 'stop_word?'
      stop_word?(message[1])
    else
      raise "Message is not understood #{message[0]}"
    end
  end

  def init
    @stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
    @stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  end

  def stop_word?(word)
    @stop_words.include? word
  end
end

# Keeps word frequency data
class WordFrequencyManager

  def dispatch(message)
    case message[0]
    when 'increment_count'
      increment_count message[1]
    when 'sorted'
      sorted
    else
      raise "Message is not understood #{message[0]}"
    end
  end

  def increment_count(word)
    if @word_freqs.nil?
      @word_freqs = Hash.new(0)
    end
    @word_freqs[word] += 1
  end

  def sorted
    @word_freqs.sort_by { |p| p[1] }.reverse
  end
end

class WordFrequencyController_12

  def dispatch(message)
    case message[0]
    when 'init'
      init message[1]
    when 'run'
      run
    else
      raise "Message is not understood #{message[0]}"
    end
  end

  def init(path_to_file)
    @storage_manager = DataStorageManager.new
    @stop_word_manager = StopWordManager.new
    @word_freq_manager = WordFrequencyManager.new

    @storage_manager.dispatch ['init', path_to_file]
    @stop_word_manager.dispatch ['init']
  end

  def run

    for w in @storage_manager.dispatch ['words']
      if not @stop_word_manager.dispatch ['stop_word?', w]
        @word_freq_manager.dispatch ['increment_count', w]
      end
    end

    word_freqs = @word_freq_manager.dispatch ['sorted']
    word_freqs.first(25).each do |tf|
      puts "#{tf[0]}-#{tf[1]}"
    end
  end
end

# The main function

wf_controller = WordFrequencyController_12.new
wf_controller.dispatch ['init', ARGV[0]]
wf_controller.dispatch ['run']
