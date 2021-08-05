#!/usr/bin/env ruby

# The functions

def extract_words(path_to_file)
  return [] if path_to_file.nil? or not path_to_file.instance_of? String

  begin
    str_data = File.read path_to_file
  rescue StandardError => e
    warn "I/O error(#{e.class}) when opening #{path_to_file}: #{e.message}"
    return []
  end
  str_data.gsub(/[\W_]+/, ' ').downcase.split
end

def remove_stop_words(word_list)
  return [] unless word_list.is_a? Array

  begin
    path_to_stop_words = '/Users/ravil/experimental/exips/stop_words.txt'
    stop_words = File.open(path_to_stop_words).read.split(',')
  rescue StandardError => e
    warn "I/O error(#{e.class}) when opening #{path_to_stop_words}: #{e.message}"
    return word_list
  end
  stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  word_list.filter { |w| !stop_words.include? w }
end

def frequencies(word_list)
  return [] unless word_list.is_a? Array
  return [] if word_list.empty?

  word_freqs = Hash.new(0)
  word_list.each { |w| word_freqs[w] += 1 }
  word_freqs
end

def sort(word_freqs)
  return {} if not word_freqs.is_a?(Hash) or word_freqs.empty?

  word_freqs.sort_by { |p| p[1] }.reverse
end

# The main function
filename = ARGV.empty? ? '../input.txt' : ARGV[0]
word_freqs = sort frequencies remove_stop_words extract_words filename
word_freqs.first(25).each { |(w, c)| puts "#{w}-#{c}" }
