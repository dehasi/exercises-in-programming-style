#!/usr/bin/env ruby

# The event management substrate
class EventManager

  def initialize
    @subscriptions = {}
  end

  def subscribe(even_type, handler)
    if @subscriptions.include? even_type
      @subscriptions[even_type].append(handler)
    else
      @subscriptions[even_type] = [handler]
    end
  end

  def publish(event)
    event_type = event[0]
    if @subscriptions.include? event_type
      @subscriptions[event_type].each { |h| h.call(event) }
    end
  end
end

# Application entities

class DataStorage

  def initialize(event_manager)
    @event_manager = event_manager
    @event_manager.subscribe(:load, ->(e) { load(e) })
    @event_manager.subscribe(:start, ->(ignore) { produce_words })

  end

  def load(event)
    path_to_file = event[1]
    @data = File.read(path_to_file).gsub(/[\W_]+/, ' ').downcase
  end

  def produce_words
    @data.split.each { |w| @event_manager.publish([:word, w]) }
    @event_manager.publish([:eof, nil])
  end
end

class StopWordsFilter

  def initialize(event_manager)
    @stop_words = []
    @event_manager = event_manager

    @event_manager.subscribe(:load, ->(ignore) { load })
    @event_manager.subscribe(:word, ->(e) { stop_word?(e) })
  end

  def load
    @stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
    @stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  end

  def stop_word?(event)
    word = event[1]
    if not @stop_words.include? word
      @event_manager.publish([:valid_word, word])
    end
  end
end

class WordFrequencyCounter

  def initialize(event_manager)
    @word_freqs = Hash.new(0)
    @event_manager = event_manager

    @event_manager.subscribe(:valid_word, ->(e) { increment_count(e) })
    @event_manager.subscribe(:print, ->(ignore) { print_freqs })
  end

  def increment_count(event)
    word = event[1]
    @word_freqs[word] += 1
  end

  def print_freqs
    @word_freqs
      .sort_by { |p| p[1] }
      .reverse.first(25)
      .each { |tf| puts "#{tf[0]}-#{tf[1]}" }
  end
end

class WordFrequencyApplication

  def initialize(event_manager)
    @event_manager = event_manager
    @event_manager.subscribe(:run, ->(e) { run(e) })
    @event_manager.subscribe(:eof, ->(e) { stop(e) })
  end

  def run(event)
    path_to_file = event[1]
    @event_manager.publish([:load, path_to_file])
    @event_manager.publish([:start, nil])
  end

  def stop(event)
    @event_manager.publish([:print, nil])
  end
end

# The main function
em = EventManager.new
DataStorage.new(em); StopWordsFilter.new(em); WordFrequencyCounter.new(em)
WordFrequencyApplication.new(em)
em.publish([:run, ARGV[0]])
