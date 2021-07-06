#!/usr/bin/env ruby

# Auxiliary functions that can't be lambdas

def extract_words(obj, path_to_file)
  obj[:data] = File.read(path_to_file)
  data_str = obj[:data].gsub(/[\W_]+/, ' ').downcase
  obj[:data] = data_str.split
end

def load_stop_words(obj)
  obj[:stop_words] = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
  obj[:stop_words] += 'abcdefghijklmnopqrstuvwxyz'.chars
end

def increment_count(obj, w)
  if obj[:freqs].include? w
    obj[:freqs][w] += 1
  else
    obj[:freqs][w] = 1
  end
end

data_storage_obj = {
  data: [],
  init: ->(path_to_file) { extract_words(data_storage_obj, path_to_file) },
  words: -> { data_storage_obj[:data] }
}

stop_words_obj = {
  stop_words: [],
  init: -> { load_stop_words(stop_words_obj) },
  is_stop_word: -> (word) { stop_words_obj[:stop_words].include?(word) }
}

word_freqs_obj = {
  freqs: {},
  increment_count: ->(w) { increment_count(word_freqs_obj, w) },
  sorted: -> { word_freqs_obj[:freqs].sort_by { |p| p[1] }.reverse }
}

data_storage_obj[:init].call ARGV[0]
stop_words_obj[:init].call

data_storage_obj[:words].call.each do |w|
  word_freqs_obj[:increment_count].call(w) unless stop_words_obj[:is_stop_word].call(w)
end

word_freqs = word_freqs_obj[:sorted].call
word_freqs.first(25).each do |tf|
  puts "#{tf[0]}-#{tf[1]}"
end