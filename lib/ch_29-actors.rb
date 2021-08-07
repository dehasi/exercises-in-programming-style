#!/usr/bin/env ruby
# frozen_string_literal: true

class ActiveWFObject
  attr_reader :queue, :thread, :stop_me
  attr_writer :stop_me

  def initialize
    @name = self.class.name
    @queue = Queue.new
    @stop_me = false
    @thread = Thread.new { run }
  end

  def run
    until @stop_me
      message = @queue.pop
      dispatch(message)
      if message[0] == :die
        @stop_me = true
      end
    end
  end

  def dispatch(message) end
end

def send(receiver, message)
  receiver.queue.push(message)
end

# Models the content of the file
class DataStorageManager < ActiveWFObject

  def dispatch(message)
    if message[0] == :init
      init(message[1..])
    elsif message[0] == :send_word_freqs
      process_words message[1..]
    else
      # forward
      send(@stop_word_manager, message)
    end
  end

  def init(message)
    path_to_file = message[0]
    @stop_word_manager = message[1]
    str_data = File.read path_to_file
    @data = str_data.gsub(/[\W_]+/, ' ').downcase
  end

  def process_words(message)
    recipient = message[0]
    words = @data.split
    words.each { |word| send(@stop_word_manager, [:filter, word]) }
    send(@stop_word_manager, [:top25, recipient])
  end
end

# Models the stop word filter
class StopWordManager < ActiveWFObject

  def dispatch(message)
    if message[0] == :init
      init(message[1..])
    elsif message[0] == :filter
      filter message[1..]
    else
      # forward
      send(@word_freqs_manager, message)
    end
  end

  def init(message)
    @stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
    @stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
    @word_freqs_manager = message[0]
  end

  def filter(message)
    word = message[0]
    unless @stop_words.include? word
      send(@word_freqs_manager, [:word, word])
    end
  end
end

# Keeps the word frequency data
class WordFrequencyManager < ActiveWFObject
  def dispatch(message)
    if message[0] == :word
      increment_count message[1..]
    elsif message[0] == :top25
      top25 message[1..]
    end
  end

  def increment_count(message)
    word = message[0]
    if @word_freqs.nil?
      @word_freqs = Hash.new(0)
    end
    @word_freqs[word] += 1
  end

  def top25(message)
    recipient = message[0]
    freqs_sorted = @word_freqs.sort_by { |p| p[1] }.reverse
    send(recipient, [:top25, freqs_sorted])
  end
end

class WordFrequencyCOntroller < ActiveWFObject

  def dispatch(message)
    if message[0] == :run
      runt message[1..]
    elsif message[0] == :top25
      display message[1..]
    else
      raise "Message not understood: #{message[0]}"
    end
  end

  def runt(message)
    @storage_manager = message[0]
    send(@storage_manager, [:send_word_freqs, self])
  end

  def display(message)
    word_freqs = message[0]
    word_freqs.first(25).each { |(w, c)| puts "#{w}-#{c}" }
    send(@storage_manager, [:die])
    @stop_me = true
  end
end

#
# The main function
#
word_freq_manager = WordFrequencyManager.new

stop_word_manager = StopWordManager.new
send(stop_word_manager, [:init, word_freq_manager])

storage_manager = DataStorageManager.new
send(storage_manager, [:init, ARGV[0], stop_word_manager])

wf_controller = WordFrequencyCOntroller.new
send(wf_controller, [:run, storage_manager])

[word_freq_manager, stop_word_manager, storage_manager, wf_controller].each { |actor| actor.thread.join }
