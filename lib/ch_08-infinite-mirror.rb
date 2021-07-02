#!/usr/bin/env ruby

# Mileage may vary. If this crashes make it lower
RECURSION_LIMIT = 8_000

def count(word_list, stop_words, word_freqs)
  # What to do with an empty list
  if word_list.empty?
    return
  else
    # The inductive case. what to do with the list of words
    # Process the head of the word
    word = word_list[0]
    if not stop_words.include? word
      if word_freqs.include? word
        word_freqs[word] += 1
      else
        word_freqs[word] = 1
      end
    end
    # Process the tail
    count(word_list[1..-1], stop_words, word_freqs)
  end
end

def wf_print(word_freqs)
  if word_freqs.empty?
    return
  else
    (w, c) = word_freqs[0]
    puts "#{w}-#{c}"
    wf_print(word_freqs[1..-1])
  end
end

stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',') #.to_set
words = File.read(ARGV[0]).downcase.scan(/[a-z]{2,}/)
word_freqs = {}
# Theoretically, we'd just call count(words, stop_words, word_freqs)
(0..words.length).step(RECURSION_LIMIT).each do |i|
  count(words[i, RECURSION_LIMIT], stop_words, word_freqs)
end

wf_print(word_freqs.sort_by { |p| p[1] }.reverse.first(25))
