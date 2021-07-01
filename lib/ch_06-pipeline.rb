#!/usr/bin/env ruby

# Ruby doesn't have 'isalnum' like Python. Let's write out own
class String
  def alnum?
    !!match(/^[[:alnum:]]+$/)
  end
end

# Takes a path to file and returns the entire content
# as a string
def read_file(path_to_file)
  File.open(path_to_file).read
end

# Takes a string and returns a copy with all nonalphanumeretic
# chars replaces by space
def filter_chars_and_normalize(str_data)
  re = Regexp.compile('[\W_]+')
  str_data.gsub(re, ' ').downcase
end

# Takes a string and scans for words
# Returns a list of words
def scan(str_data)
  str_data.split
end

# Takes a list of words
# Returns a copy with all stop words removed
def remove_stop_words(word_list)
  stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
  stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  word_list.filter { |w| !stop_words.include? w }
end

# Takes a list of words
# Returns a dictionary with associating words with frequencies of occurrence
def frequencies(word_list)
  word_freqs = {}
  for w in word_list
    if word_freqs.include? w
      word_freqs[w] += 1
    else
      word_freqs[w] = 1
    end
  end
  return word_freqs
end

# Takes a dictionary of words and their frequencies
# Returns a list of pairs
# Where the entries are sorted by frequency
def sort(word_freq)
  word_freq.each_pair.sort_by { |x| x[1] }.reverse
end

# Takes a list of pairs
# Where the entries a sorted by frequency
# Prints them recursively
def print_all(word_freqs)
  if word_freqs.length > 0
    puts "#{word_freqs[0][0]}-#{word_freqs[0][1]}"
    print_all(word_freqs[1...word_freqs.length])
  end
end

# The main function
print_all(sort(frequencies(remove_stop_words(scan(
                                               filter_chars_and_normalize(read_file(ARGV[0]))))))[0...25])
