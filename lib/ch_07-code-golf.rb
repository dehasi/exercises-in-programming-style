#!/usr/bin/env ruby

stops = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
words = File.read(ARGV[0]).downcase.scan(/[a-z]{2,}/).filter { |w| !stops.include? w }
counts = words.group_by(&:itself).transform_values(&:size) # .reduce(Hash.new(0)) { |h, w| h[w] += 1; h } # .tally
              .each_pair.sort_by { |p| -p[1] }
counts.first(25).each do |w, c|
  puts "#{w}-#{c}"
end