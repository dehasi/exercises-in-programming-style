#!/usr/bin/env ruby
# frozen_string_literal: true

require 'fiber'

# Ruby doesn't have 'isalnum' like Python. Let's write out own
class String
  def alnum?
    !!match(/^[[:alnum:]]+$/)
  end
end

def characters(filename)
  Fiber.new do
    File.readlines(filename).each do |line|
      line.chars.each do |c|
        Fiber.yield c
      end
    end
    '' # I have to add it, otherwise fiber returns the whole array on the last iteration
  end
end

def all_words(filename)
  Fiber.new do
    start_char = true
    fiber = characters(filename)
    while fiber.alive?
      c = fiber.resume
      if start_char
        word = ''
        if c.alnum?
          # We found the start of a word
          word += c.downcase
          start_char = false
        end
      else
        if c.alnum?
          word += c.downcase
        else
          # We found end of a word, emit it
          start_char = true
          Fiber.yield word
        end
      end
    end
  end
end

def non_stop_words(filename)
  Fiber.new do
    stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
    stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars

    fiber = all_words(filename)
    while fiber.alive?
      word = fiber.resume
      Fiber.yield word unless stop_words.include? word
    end
  end
end

def count_and_sort(filename)
  Fiber.new do
    freqs, i = Hash.new(0), 1

    fiber = non_stop_words(filename)
    while fiber.alive?
      word = fiber.resume
      freqs[word] += 1
      Fiber.yield freqs.sort_by { |p| p[1] }.reverse if (i % 5000).zero?
      i += 1
    end
    Fiber.yield freqs.sort_by { |p| p[1] }.reverse
  end
end

fiber = count_and_sort(ARGV[0])
prev = wf = nil
# we need only the last, but count_and_sort yields every 5000th time
prev, wf = wf, fiber.resume while fiber.alive?

prev&.first(25)&.each { |(w, c)| puts "#{w}-#{c}" }
