def top25(word_list)
  word_list.group_by(&:itself)
           .transform_values(&:size) # .reduce(Hash.new(0)) { |h, w| h[w] += 1; h } # .tally
           .sort_by { |p| -p[1] }
           .first(25)
end
