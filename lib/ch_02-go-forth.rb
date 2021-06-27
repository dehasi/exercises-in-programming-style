#!/usr/bin/env ruby

# The all-important data stack
$stack = [] # '$' is needed for globals

# The heap. Maps names to data (i.e. variables)
$heap = {}

# Takes path to file from the stack
# Places the entire contents of the file back to the stack
def read_file
  f = File.open($stack.pop)
  $stack.push(f.read)
  f.close
end

# Takes data on the stack
# Places back the copy of all non nonalphanumeretic chars replaced by space
def filter_chars
  # In Python we apply a string to a regexp,
  # but in Ruby we apply a regexp to a string, that's why we don't have to append
  $stack.push($stack.pop().gsub(Regexp.compile('[\W_]+'), ' ').downcase)
end

# Takes a string on the stack and scans for words,
# placing the list of the words back on the stack
def scan
  # Ruby's 'extend' is a different from Python's
  $stack += $stack.pop.split
end

# Takes a list of words on the stack and removes stop words
def remove_stop_words
  f = File.open('/Users/ravil/experimental/exips/stop_words.txt')
  $stack.push(f.read.split(','))
  f.close
  # add single letter words
  $stack[-1] += 'abcdefghijklmnopqrstuvwxyz'.chars # Python's list(string.ascii_lowercase)
  $heap[:stop_words] = $stack.pop
  $heap[:words] = []
  while $stack.length > 0
    if $heap[:stop_words].include? $stack.last
      $stack.pop
    else
      $heap[:words].append $stack.pop # pop it, store it
    end
  end
  $stack += $heap[:words] # Load the words onto the stack
  $heap[:stop_words] = nil; $heap[:words] = nil # Not needed
end

# Takes a list of the words and
# returns a dictionary associating words with frequencies of occurrence
def frequencies
  $heap[:word_freqs] = {}
  $heap[:count] = 0 # we need because of operator order, see below
  # A little flavour of the real Forth style here...
  while $stack.length > 0
    # ...but the following line is not in style, because the 
    # naive implementation would be too slow
    if $heap[:word_freqs].include? $stack.last
      # Increment the frequency, postfix style: f 1 +
      $stack.push $heap[:word_freqs][$stack.last] # push f
      $stack.push 1
      $stack.push $stack.pop + $stack.pop
    else
      $stack.push 1
    end
    # Load the updated freq back onto heap
    $heap[:count] = $stack.pop
    $heap[:word_freqs][$stack.pop] = $heap[:count] # can't write head[_][stack.pop] = stack.pop
  end
  # Push result onto the stack
  $stack.push $heap[:word_freqs]
  $heap[:word_freqs] = nil; $heap[:count] = nil # Don't need this variable
end

def sort
  $stack += $stack.pop.sort_by { |_, v| v }
end

# The main function
$stack.push(ARGV[0])
read_file; filter_chars; scan; remove_stop_words; frequencies; sort

$stack.push 0

# Check stack length against 1, because after we process
# the last word there will be one item left
while $stack.last < 25 and $stack.length > 1
  $heap[:i] = $stack.pop
  (w, f) = $stack.pop; puts "#{w}-#{f}"
  $stack.push $heap[:i]; $stack.push 1
  $stack.push $stack.pop + $stack.pop
end

