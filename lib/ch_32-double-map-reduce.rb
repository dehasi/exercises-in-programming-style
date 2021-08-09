#!/usr/bin/env ruby
# frozen_string_literal: true
require 'fiber'
# Functions for map reduce

# Partitions the input 'data_str' (a big string)
# into chunks of lines
def partition(data_str, nlines)
  lines = data_str.split("\n")
  Fiber.new do
    (0...lines.size).step(nlines).each do |i|
      Fiber.yield lines[i...(i + nlines)].join "\n"
    end
    '' # I have to add it, otherwise fiber returns the whole array on the last iteration
  end
end

# Takes a string, returns a list of pairs (word, 1),
# one for each word in th input, so
# [(w1, 1), (w2, 1), ..., (wn, 1)]
def split_words(data_str)

  def _scan(str_data)
    str_data.gsub(/[\W_]+/, ' ').downcase.split
  end

  def _remove_stop_words(word_list)
    stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
    stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
    word_list.filter { |word| !stop_words.include? word }
  end

  # The actual work of splitting the input into words
  result = []
  words = _remove_stop_words(_scan(data_str))
  words.each { |w| result.append([w, 1]) }
  return result
end

# Takes a list of lists of pairs of the form
# [[(w1, 1), (w2, 1), ..., (wn, 1)],
#  [(w1, 1), (w2, 1), ..., (wn, 1)],
#  ...]
# and returns a dictionary mapping each unique word to the
# correcponing list of pairs, so
# {w1: [(w1, 1), (w1, 1)...],
#  w2: [(w2, 1), (w2, 1)...],
#  ...}
def regroup(pairs_list)
  mapping = {}
  pairs_list.each do |pairs|
    pairs.each do |p|
      mapping[p[0]] = [] unless mapping.include? p[0]
      mapping[p[0]].append p
    end
  end
  mapping
end

# Takes a mapping of the form (word, [(word, 1), (word, 1)...])
# and returns a pair (word, frequency), where frequency is the
# sum of all reported occurrences
def count_words(mapping)
  [mapping[0], mapping[1].map { |p| p[1] }.reduce { |x, y| x + y }]
end

# Auxiliary functions
def read_file(path_to_file)
  File.read path_to_file
end

def sort(word_freq)
  word_freq.sort_by { |p| p[1] }.reverse
end

# The main function
partitions = [] # As ruby don't have generators, I iterate in a loop
fiber = partition(read_file(ARGV[0]), 200)
partitions.append(fiber.resume) while fiber.alive?

splits = partitions.map { |str| split_words(str) }
splits_per_word = regroup(splits)
word_freqs = sort(splits_per_word.map { |mapping| count_words(mapping) })

word_freqs.first(25).each { |(w, c)| puts "#{w}-#{c}" }
