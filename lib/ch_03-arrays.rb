#!/usr/bin/env ruby

# Ruby doesn't have 'isalpha' like Python. Let's write out own
class String
  def isalpha? # https://stackoverflow.com/a/60711379/4337151
    !!match(/^[[:alpha:]]+$/)
  end
end

characters = [' '] + File.open(ARGV[0]).read.chars + [' ']

# Normalize
# Ruby doesn't have numpy, but we can make inplace transformations using map!
characters.map! { |ch|
  if ch.isalpha?
    ch.downcase
  else
    ' '
  end
}

# Split the words by finding indices of spaces
sp = characters.each_index.select { |i| characters[i] == ' ' }
# A little trick: let's double each index, and then take pairs
sp2 = sp.flat_map { |item| Array.new(2, item) }
# Get the pairs as a 2D matrix, skip the first and the last
w_ranges = sp2[1...-1].each_slice(2).to_a

# remove indexing to the spaces themselves
w_ranges = w_ranges.select { |range| range[1] - range[0] > 2 }

# Voila! Words are between spaces, given as pairs of indexes
words = w_ranges.map { |range| characters[range[0]...range[1]] }
# Let's recode characters as strings
swords = words.map { |w| w.join('').strip }

# Next, let's remvoe stop words
stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
ns_words = swords.select { |w| not stop_words.include? w }

# Finally, count the word occurrences
# uniq, counts = ns_words.to_h{ |name| [name, ns_words.count(name)] }
# uniq, counts = ns_words.tally # since Ruby 2.7
uniq_counts = ns_words.group_by(&:itself).transform_values(&:count).to_a
wf_sorted = uniq_counts.sort_by { |pair| pair[1] }.reverse

wf_sorted.first(25).each do |w, c|
  puts "#{w}-#{c}"
end
