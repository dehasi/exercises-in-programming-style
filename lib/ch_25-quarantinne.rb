#!/usr/bin/env ruby

# The Quarantine class for this example
class TFQuarantine

  def initialize(func)
    @funcs = [func]
  end

  def bind(func)
    @funcs.append(func)
    self
  end

  def execute
    def guard_callable(v)
      return v.call if v.is_a? Proc
      return v
    end

    value = -> { nil }
    @funcs.each { |func| value = func.call(guard_callable(value)) }
    puts guard_callable(value)
  end
end

# The functions

get_input = lambda do |arg|
  -> { ARGV[0] }
end

extract_words = lambda do |path_to_file|
  -> { File.read(path_to_file).gsub(/[\W_]+/, ' ').downcase.split }
end

remove_stop_words = lambda do |word_list|
  lambda do
    stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
    stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars

    word_list.filter { |w| !stop_words.include? w }
  end
end

frequencies = lambda do |word_list|
  word_freqs = Hash.new(0)
  word_list.each { |w| word_freqs[w] += 1 }
  word_freqs
end

sort = lambda do |word_freq|
  word_freq.sort_by { |p| p[1] }.reverse
end

top25_freqs = lambda do |word_freq|
  word_freq.first(25).reduce('') { |concat, (w, c)| concat + "#{w}-#{c}\n" }
end

# The main function
TFQuarantine.new(get_input)
            .bind(extract_words)
            .bind(remove_stop_words)
            .bind(frequencies)
            .bind(sort)
            .bind(top25_freqs)
            .execute
