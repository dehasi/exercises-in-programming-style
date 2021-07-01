#!/usr/bin/env ruby

# Ruby doesn't have 'isalnum' like Python. Let's write out own
class String
  def alnum?
    !!match(/^[[:alnum:]]+$/)
  end
end

# The shared mutable data

$data = []
$words = []
$word_freqs = []

# The procedres

# Takes a path to file and assigns the entire
# content of the file to the global variable data

def read_file(path_to_file)
  $data = File.open(path_to_file).read.chars
end

# Replaces all nonaplhanumeretic chars in data with white space
def filter_chars_and_normalize
  for i in 0...$data.length
    if not $data[i].alnum?
      $data[i] = ' '
    else
      $data[i] = $data[i].downcase
    end
  end
end

# Scans data for words, filling the global variable 'words'
def scan
  data_str = $data.join('')
  $words = $words + data_str.split
end

def remove_stop_words
  stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
  stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  indexes = []

  for i in 0...$words.length
    if stop_words.include? $words[i]
      indexes.append(i)
    end
  end

  for i in indexes.reverse
    $words.delete_at(i)
  end
end

# Creates a list of pairs associated words with frequencies.
def frequencies

  for w in $words
    keys = $word_freqs.map { |wd| wd[0] }
    if keys.include? w
      $word_freqs[keys.index(w)][1] += 1
    else
      $word_freqs.append([w, 1])
    end
  end
end

# Sorts word_freqs by frequency
def sort
  $word_freqs.sort_by! { |x| x[1] }.reverse!
end

# The main function
read_file(ARGV[0])
filter_chars_and_normalize
scan
remove_stop_words
frequencies
sort

for tf in $word_freqs[0...25] do
  puts "#{tf[0]}-#{tf[1]}"
end