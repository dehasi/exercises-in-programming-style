#!/usr/bin/env ruby
# frozen_string_literal: true

# Queue.pop doesn't have timeout option, so I googled a workaround
def pop_with_timeout(q, timeout = 1)
  start_time = Time.now
  t = start_time
  loop do
    begin
      return q.pop(true)
    rescue ThreadError => e
      if t < start_time + timeout
        sleep 0.01
        t = Time.now
      else
        raise e
      end
    end
  end
end

# Two data spaces
$word_space = Queue.new
$freq_space = Queue.new

$stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
#stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars

# Worker function that consumes words from the 'word_space'
# and sends partial results to the 'freq_space'
def process_words
  word_freqs = Hash.new(0)

  loop do
    begin
      word = pop_with_timeout($word_space)
    rescue ThreadError
      break
    end
    word_freqs[word] += 1 unless $stop_words.include? word
  end
  $freq_space.push word_freqs
end

# Let's have this thread populate the word space
File.read(ARGV[0]).downcase.scan(/[a-z]{2,}/).each { |word| $word_space.push word }

# Let's create the workers and launch them at their jobs
workers = []
5.times { workers.append(Thread.new { process_words }) }

# Let's wait for the worker finish
workers.each(&:join)

# Let's merge the partial frequency results by consuming
# frequency data from the 'freq_space'
word_freqs = {}
until $freq_space.empty?
  freqs = $freq_space.pop
  word_freqs.merge!(freqs) { |key, oldval, newval| newval + oldval }
end

word_freqs
  .sort_by { |p| p[1] }.reverse
  .first(25)
  .each { |(w, c)| puts "#{w}-#{c}" }
