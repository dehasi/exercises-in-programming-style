#!/usr/bin/env ruby

# The columns. Each column is a data element and a formula
# The first 2 columns are the input data, so no formulas

all_words = [(), nil]
stop_words = [(), nil]
non_stop_words = [(), -> { all_words[0].map { |w| stop_words[0].include?(w) ? '' : w } }]

unique_words = [(), -> { non_stop_words[0].filter { |w| w != '' } }]

counts = [(), -> { unique_words[0].map { |w| non_stop_words[0].count(w) } }]

sorted_data = [(), -> { unique_words[0].zip(counts[0]).to_h.sort_by { |p| p[1] }.reverse }]

# The entire spreadsheet
$all_columns = [all_words, stop_words, non_stop_words, unique_words, counts, sorted_data]

# The active procedure over the columns of data.
# Call this everytime the input data changes, or periodically
def update
  $all_columns.each do |col|
    col[0] = col[1].call unless col[1].nil?
  end
end

# Load the fixed data into the first 2 columns
all_words[0] = File.read(ARGV[0]).downcase.scan(/[a-z]{2,}/)
stop_words[0] = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',') #.to_set
update

sorted_data[0].first(25).each do |(w, c)|
  puts "#{w}-#{c}"
end
