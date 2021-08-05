require_relative 'config'

word_freqs = top25(extract_words(ARGV[0]))
word_freqs.first(25).each { |(w, c)| puts "#{w}-#{c}" }
