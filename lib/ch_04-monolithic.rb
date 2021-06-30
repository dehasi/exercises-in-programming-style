#!/usr/bin/env ruby

# Ruby doesn't have 'isalpha' like Python. Let's write out own
class String
  def isalpha? # https://stackoverflow.com/a/60711379/4337151
    !!match(/^[[:alpha:]]+$/)
  end
end

# Ruby doesn't have 'isalnum' like Python. Let's write out own
class String
  def alnum?
    !!match(/^[[:alnum:]]+$/)
  end
end

# the global list of [word, frequency] pairs
word_freqs = []
# The list of stop words
stop_words = []
File.foreach('/Users/ravil/experimental/exips/stop_words.txt') do |line|
  stop_words = line.split(',')
end
stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars

# iterate thru thr file one line at a time
for line in File.open(ARGV[0]) do
  start_char = nil
  i = 0
  for c in line.each_char do
    if start_char == nil
      if c.alnum?
        # We found the start of a word
        start_char = i
      end
    else
      if not c.alnum?
        # We found end of a word. Process it
        found = false
        word = line[start_char...i].downcase
        # Ignore stop words
        if not stop_words.include? word
          pair_index = 0
          # Let's see if it already exists
          for pair in word_freqs
            if word == pair[0]
              pair[1] += 1
              found = true
              break
            end
            pair_index += 1
          end
          if not found
            word_freqs.append([word, 1])
          elsif word_freqs.length > 1
            # we may need to reorder
            for n in (0..pair_index).reverse_each
              if word_freqs[pair_index][1] > word_freqs[n][1]
                #swap
                word_freqs[n], word_freqs[
                  pair_index] = word_freqs[
                  pair_index], word_freqs[n]
                pair_index = n
              end
            end
          end
        end
        # Let's reset
        start_char = nil
      end
    end
    i += 1
  end
end

for tf in word_freqs[0...25] do
  puts "#{tf[0]}-#{tf[1]}"
end