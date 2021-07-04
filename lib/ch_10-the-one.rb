#!/usr/bin/env ruby

# The one class for this example
class TFTheOne

  def initialize(value)
    @value = value
  end

  def bind(func)
    @value = method(func).call(@value)
    self
  end

  def print_me
    puts @value
  end
end

# The functions
def read_file(path_to_file)
  File.read(path_to_file)
end

def filter_chars(str_data)
  str_data.gsub(/[\W_]+/, ' ')
end

def normalize(str_data)
  str_data.downcase
end

def scan(str_data)
  str_data.split
end

def remove_stop_words(word_list)
  stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
  stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  word_list.filter { |w| !stop_words.include? w }
end

def frequencies(word_list)
  word_freqs = Hash.new(0)
  word_list.each { |w| word_freqs[w] += 1 }
  word_freqs
end

def sort(word_freqs)
  word_freqs.sort_by { |p| p[1] }.reverse
end

def top25_freqs(word_freqs)
  top25 = ""
  word_freqs.first(25).each do |tf|
    top25 += "#{tf[0]}-#{tf[1]}\n"
  end
  top25
end

# The main function
TFTheOne.new(ARGV[0])
        .bind(:read_file)
        .bind(:filter_chars)
        .bind(:normalize)
        .bind(:scan)
        .bind(:remove_stop_words)
        .bind(:frequencies)
        .bind(:sort)
        .bind(:top25_freqs)
        .print_me
