#!/usr/bin/env ruby

# This function can only be called from a function names 'extract_words'
def read_stop_words
  # Meta-level: caller & caller_locations (inspect.stack in python)
  # p caller
  # p caller_locations.last(5).inspect
  if caller_locations[-3].label != 'extract_words'
    p caller_locations.last(5).inspect # just for debug
    return nil
  end
  stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
  stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  stop_words
end

def extract_words(path_to_file)
  # local_variables.inspect returns arrays of symbols '[:path_to_file]'
  # binding.local_variable_get(:path_to_file) return valur
  # Meta-level binding (locals() in python)
  word_list = File.read(binding.local_variable_get(local_variables[0]))
                  .gsub(/[\W_]+/, ' ').downcase.split

  stop_words = read_stop_words
  word_list.filter { |word| !stop_words.include?(word) }
end

def frequencies(word_list)
  # Meta-level binding
  word_freqs = Hash.new(0)
  binding.local_variable_get(:word_list).each do |w|
    word_freqs[w] += 1
  end
  word_freqs
end

def sort(word_freqs)
  # Meta-level binding
  binding.local_variable_get(:word_freqs)
         .sort_by { |p| p[1] }
         .reverse
end

def main
  word_freqs = sort(frequencies(extract_words(ARGV[0])))
  for (w, c) in word_freqs.first(25)
    puts "#{w}-#{c}"
  end
end

if __FILE__ == $0
  main
end