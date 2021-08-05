#!/usr/bin/env ruby

# The functions

# As Ruby doesn't have an idiomatic assert, I wrote my own
def assert(condition, msg = 'Assertion failed!')
  raise msg unless condition
end

def extract_words(path_to_file)
  assert path_to_file.instance_of?(String), 'I need a String'

  begin
    str_data = File.read path_to_file
  rescue StandardError => e
    warn "I/O error(#{e.class}) when opening #{path_to_file}: #{e.message}! I quit"
    raise e
  end
  str_data.gsub(/[\W_]+/, ' ').downcase.split
end

def remove_stop_words(word_list)
  assert word_list.is_a?(Array), 'I need an Array'

  begin
    path_to_stop_words = '/Users/ravil/experimental/exips/stop_words.txt'
    stop_words = File.open(path_to_stop_words).read.split(',')
  rescue StandardError => e
    warn "I/O error(#{e.class}) when opening #{path_to_stop_words}: #{e.message}! I quit!"
    raise e
  end
  stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  word_list.filter { |w| !stop_words.include? w }
end

def frequencies(word_list)
  assert word_list.is_a?(Array), 'I need an Array'
  assert !word_list.empty?, 'I need non-empty Array'

  word_freqs = Hash.new(0)
  word_list.each { |w| word_freqs[w] += 1 }
  word_freqs
end

def sort(word_freqs)
  assert word_freqs.is_a?(Hash), 'I need a Hash'
  assert !word_freqs.empty?, 'I need non-empty Hash'

  begin
    word_freqs.sort_by { |p| p[1] }.reverse
  rescue StandardError => e
    warn "Sort threw #{e}"
    raise e
  end
end

# The main function
begin
  assert !ARGV.empty?, 'You idiot! I need an input file'
  word_freqs = sort frequencies remove_stop_words extract_words ARGV[0]

  assert word_freqs.is_a?(Array), 'OMG! This is not an Array'
  assert word_freqs.size > 25, 'SRSLY? Less than 25 words'
  word_freqs.first(25).each { |(w, c)| puts "#{w}-#{c}" }
rescue StandardError => e
  warn "Something went wrong: #{e}"
  warn e.backtrace
end
