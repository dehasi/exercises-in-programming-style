#!/usr/bin/env ruby

# Two down-to-earth things

stops = File.read('/Users/ravil/experimental/exips/stop_words.txt').split(',') + 'abcdefghijklmnopqrstuvwxyz'.chars

def frequencies_impl(word_list)
  word_freqs = Hash.new(0)
  word_list.each { |w| word_freqs[w] += 1 }
  word_freqs
end

# Let's write our own functions as strings
if not ARGV.empty?
  extract_words_func = '->(name) { File.read(name).downcase.scan(/[a-z]{2,}/).filter { |word| !stops.include? word } }'
  frequencies_func = '->(wl) { frequencies_impl(wl) }'
  sort_func = '->(word_freq) { word_freq.sort_by { |p| -p[1] } }'
  file_name = ARGV[0]
else
  extract_words_func = '->(x) { [] }'
  frequencies_func = '->(x) { [] }'
  sort_func = '->(x) { [] }'
  file_name = File.basename(__FILE__)
end

extract_words = '' # Ruby can't create local variables, even ' binding.local_variable_set' can't
eval("extract_words = #{extract_words_func}")
frequencies = eval(frequencies_func)
sort = ''
eval("sort = #{sort_func}")

# The main function. This would work just fine:
# word_freqs = sort(frequencies(extract_words(file_name)))
#
word_freqs = binding.local_variable_get(:sort).call(
  binding.local_variable_get(:frequencies).call(
    binding.local_variable_get(:extract_words).call(file_name)))

word_freqs.first(25).each { |(w, c)| puts "#{w}-#{c}" }
