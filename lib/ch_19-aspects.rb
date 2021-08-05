#!/usr/bin/env ruby

# The functions

extract_words = ->(path_to_file) {
  str_data = File.read path_to_file
  word_list = str_data.gsub(/[\W_]+/, ' ').downcase.split
  stop_words = File.read('/Users/ravil/experimental/exips/stop_words.txt').split(',')
  stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  word_list.filter { |w| !stop_words.include? w }
}

frequencies = ->(word_list) {
  word_freqs = Hash.new(0)
  word_list.each { |w| word_freqs[w] += 1 }
  word_freqs
}

sort = -> (word_freq) {
  word_freq.sort_by { |p| p[1] }.reverse
}

def profile(f)
  ->(*arg) {
    start_time = Time.now
    return_value = f.call(*arg)
    elapsed = Time.now - start_time
    STDERR.puts "#{f}(...) took #{elapsed} secs"
    return_value
  }
end

# join points
tracked_functions = %i[extract_words frequencies sort]
# weaver
tracked_functions.each do |func|
  # I can't reassign methods in Ruby, that's why I use variables and lambdas
  binding.local_variable_set(func, profile(binding.local_variable_get(func)))
end

word_freqs = sort.call(frequencies.call(extract_words.call(ARGV[0])))
word_freqs.first(25).each { |(w, c)| puts "#{w}-#{c}" }
