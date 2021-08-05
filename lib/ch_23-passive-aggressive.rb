#!/usr/bin/env ruby

# The functions

# As Ruby doesn't have an idiomatic assert, I wrote my own
def assert(condition, msg = 'Assertion failed! I quit!')
  raise msg unless condition
end

def extract_words(path_to_file)
  assert path_to_file.instance_of?(String), 'I need a String! I quit!'

  File.read(path_to_file).gsub(/[\W_]+/, ' ').downcase.split
end

def remove_stop_words(word_list)
  assert word_list.is_a?(Array), 'I need an Array! I quit!'

  stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
  stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  word_list.filter { |w| !stop_words.include? w }
end

def frequencies(word_list)
  assert word_list.is_a?(Array), 'I need an Array! I quit!'
  assert !word_list.empty?, 'I need non-empty Array! I quit!'

  word_freqs = Hash.new(0)
  word_list.each { |w| word_freqs[w] += 1 }
  word_freqs
end

def sort(word_freqs)
  assert word_freqs.is_a?(Hash), 'I need a Hash! I quit!'
  assert !word_freqs.empty?, 'I need non-empty Hash! I quit!'

  word_freqs.sort_by { |p| p[1] }.reverse
end

# The main function
begin
  assert !ARGV.empty?, 'You idiot! I need an input file'
  word_freqs = sort frequencies remove_stop_words extract_words ARGV[0]

  assert word_freqs.size > 25, 'SRSLY? Less than 25 words'
  word_freqs.first(25).each { |(w, c)| puts "#{w}-#{c}" }
rescue StandardError => e
  warn "Something went wrong: #{e}"
  warn e.backtrace
end
