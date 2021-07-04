#!/usr/bin/env ruby

#
# The functions
#
def read_file(path_to_file, func)
  data = File.read(path_to_file)
  func.call(data, method(:normalize))
end

def filter_chars(str_data, func)
  func.call(str_data.gsub(/[\W_]+/, ' '), method(:scan))
end

def normalize(str_data, func)
  func.call(str_data.downcase, method(:remove_stop_words))
end

def scan(str_data, func)
  func.call(str_data.split, method(:frequencies))
end

def remove_stop_words(word_list, func)
  stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
  stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  func.call(word_list.filter { |w| !stop_words.include? w }, method(:sort))
end

def frequencies(word_list, func)
  wf = Hash.new(0)
  word_list.each { |w| wf[w] += 1 }
  func.call(wf, method(:print_text))
end

def sort(wf, func)
  func.call(wf.sort_by { |p| p[1] }.reverse, method(:no_op))
end

def print_text(word_freqs, func)
  word_freqs.first(25).each { |w, c| puts "#{w}-#{c}" }
  func.call(nil)
end

def no_op(func) end

# The main function
read_file(ARGV[0], method(:filter_chars))

# The call-chain
# read_file -> filter_chars(normalize)
# filter_chars -> normalize(scan)
# normalize -> scan(remove_stop_words)
# scan -> remove_stop_words(frequencies)
# remove_stop_words -> frequencies(sort)
# frequencies -> sort(print_text)
# sort -> print_text(no_op)
# no_op

