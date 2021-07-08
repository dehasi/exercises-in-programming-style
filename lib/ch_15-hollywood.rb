#!/usr/bin/env ruby

# The "I'll call you back" Word Frequency Framework

class WordFrequencyFramework

  def initialize
    @load_event_handlers = []
    @dowork_event_handlers = []
    @end_event_handlers = []
  end

  def register_for_load_event(handler)
    @load_event_handlers.append(handler)
  end

  def register_for_dowork_event(handler)
    @dowork_event_handlers.append(handler)
  end

  def register_for_end_event(handler)
    @end_event_handlers.append(handler)
  end

  def run(path_to_file)
    for h in @load_event_handlers
      h.call(path_to_file)
    end

    for h in @dowork_event_handlers
      h.call
    end

    for h in @end_event_handlers
      h.call
    end
  end
end

# The entities of the application
class DataStorage

  def initialize(wfapp, stop_words_filter)
    @stop_words_filter = stop_words_filter
    @word_even_handlers = []
    wfapp.register_for_load_event(->(x) { load(x) })
    wfapp.register_for_dowork_event(-> { produce_words })
  end

  def load(path_to_file)
    @data = File.read(path_to_file).gsub(/[\W_]+/, ' ').downcase.split
  end

  def produce_words
    for w in @data.split
      if not @stop_words_filter.stop_word? w
        for h in @word_even_handlers
          h.call(w)
        end
      end
    end
  end

  def register_for_word_event(handler)
    @word_even_handlers.append(handler)
  end
end

class StopWordsFilter

  def initialize(wfapp)
    wfapp.register_for_load_event(-> (ignore) { load })
  end

  def load
    @stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
    @stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  end

  def stop_word?(word)
    @stop_words.include? word
  end
end

class WordFrequencyCounter

  def initialize(wfapp, data_storage)
    @word_freqs = Hash.new(0)
    data_storage.register_for_word_event(->(w) { increment_count(w) })
    wfapp.register_for_end_event(-> { print_freqs })
  end

  def increment_count(word)
    @word_freqs[word] += 1
  end

  def print_freqs
    @word_freqs
      .sort_by { |p| p[1] }
      .reverse.first(25)
      .each { |tf| puts "#{tf[0]}-#{tf[1]}" }
  end
end

# The main function
wfapp = WordFrequencyFramework.new
stop_word_filter = StopWordsFilter.new(wfapp)
data_storage = DataStorage.new(wfapp, stop_word_filter)
word_freq_counter = WordFrequencyCounter.new(wfapp, data_storage)
wfapp.run(ARGV[0])