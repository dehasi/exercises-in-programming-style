#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fiber'

$lock = Mutex.new
$stop = false

# The active view

class FreqObserver

  attr_reader :thread

  def initialize(freqs)
    @daemon, @end = true, false
    @freqs = freqs
    @freqs0 = @freqs.sort_by { |p| p[1] }.reverse.first(25)
    @thread = Thread.new { run }
  end

  def run
    until @end
      _update_view
      sleep(0.1)
    end
    _update_view
  end

  def stop
    @end = true
  end

  def _update_view
    $lock.lock
    freqs1 = @freqs.sort_by { |p| p[1] }.reverse.first(25)
    $lock.unlock
    if freqs1 != @freqs0
      _update_display freqs1
      @freqs0 = freqs1
    end
  end

  def _update_display(tuples)
    def refresh_screen(data)
      # clear screem
      # STDOUT.clear_screen
      warn '---------------------------'
      puts data
      STDOUT.flush
    end

    data_str = tuples.reduce('') { |concat, (w, c)| concat + "#{w}-#{c}\n" }
    refresh_screen data_str
  end
end

# The model
class WordsCounter
  attr_reader :freqs

  def initialize
    @freqs = Hash.new(0)
    @first_time = true
  end

  def count(f)
    word = next_non_stop_words(f)
    $lock.lock
    if !word.nil?
      @freqs[word] += 1
    else
      $stop = true
    end
    $lock.unlock
  end

  def next_non_stop_words(f)
    if @first_time
      @fiber = non_stop_words(f)
      @first_time = false
    end
    @fiber.resume if @fiber.alive?
  end

  def non_stop_words(f)
    stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
    stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
    Fiber.new do
      File.readlines(f).each do |line|
        line.downcase.scan(/[a-z]{2,}/).each do |word|
          Fiber.yield word unless stop_words.include? word
        end
      end
      nil
    end
  end
end

model = WordsCounter.new
view = FreqObserver.new(model.freqs)

warn 'Press space bar to fetch words from the file one by one'
until $stop
  begin
    # sleep(0.1)
    model.count(ARGV[0])
  rescue StandardError => e
    warn e
    view.stop
    break
  end
end
view.stop
view.thread.join
