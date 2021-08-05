def top25(word_list)
  word_freqs = Hash.new(0)
  word_list.each { |w| word_freqs[w] += 1 }
  word_freqs.sort_by { |p| p[1] }.reverse
            .first(25)
end
