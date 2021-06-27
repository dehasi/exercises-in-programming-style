#!/usr/bin/env ruby

# Ruby doesn't have 'isalnum' like Python. Let's write out own
class String
  def alnum?
    !!match(/^[[:alnum:]]+$/)
  end
end

# Utility for handling the intermediate 'second memory'
def touchopen(filename, *args)
  begin
    File.delete(filename)
  rescue Errno::ENOENT
  end
  File.open(filename, 'a').close # touch file
  return File.open(filename, *args)
end

# The constant memory should not have no more than 1024 cells
data = []
# PART 1
# Load list of stop words
f = File.open('/Users/ravil/experimental/exips/stop_words.txt')

data = [f.read(1024).split(',')] # data[0] holds the stop words
f.close

data.append([]) # data[1] is line (max 80 characters)
data.append(nil) # data[2] is index of the start_char of word
data.append(0) # data[3] is index on characters
data.append(false) # data[4] is flag indicating if word was found
data.append('') # data[5] is the word
data.append('') # data[6] is word,NNN
data.append(0) # data[7] is frequency

# Open the secondary memory
word_freqs = touchopen('word_freqs', 'rb+')
# Open the input file
f = File.open(ARGV[0], 'r')
#  Loop over input file's lines
while true
  data[1] = [f.gets]
  if data[1] == [nil] # end of input file
    break
  end

  if data[1][0][data[1][0].length - 1] != "\n" # if does not ends with \n
    data[1][0] = data[1][0] + "\n" # Add \n
  end
  data[2] = nil
  data[3] = 0

  # Loop over characters in the line
  data[1][0].each_char.each do |c| # elimination of sumbol c is exersise
    if data[2] == nil
      if c.alnum? # we found the start of the word
        data[2] = data[3]
      end
    else
      if not c.alnum?
        # we found the end of a word. Process it
        data[4] = false
        data[5] = data[1][0][data[2]...data[3]].downcase
        # Ignore words with len < 2, and stop words
        if data[5].length >= 2 and not data[0].include? data[5]
          while true
            data[6] = word_freqs.gets #  we read word,NNNN
            if data[6] == nil
              break
            end
            data[7] = data[6].split(',')[1].to_i # we split word,NNN and get NNN
            # word, no whitespace
            data[6] = data[6].split(',')[0].strip # we split word,NNN and get word
            if data[5] == data[6]
              data[7] += 1
              data[4] = true
              break
            end
          end
          if not data[4]
            word_freqs.seek(0, IO::SEEK_CUR) # Needed i WI=indows
            word_freqs.write("%20s,%04d\n" % [data[5], 1]) # 26 chars per line 20s + ',' +  4d + '\n'
          else
            word_freqs.seek(-26, IO::SEEK_CUR)
            word_freqs.write("%20s,%04d\n" % [data[5], data[7]])
          end
          word_freqs.seek(0, IO::SEEK_SET)
        end
        # Let's reset
        data[2] = nil
      end
    end
    data[3] += 1
  end
end
# We're done with the input file
f.close
word_freqs.flush

# PART 2
# We don't need anything from the previous memory
(0..data.length).each do |i|
  # Ruby doesn't have del data[:] like python
  data[i] = []
end

# Let's use the first 25 entries for the top 25 words
data = data + [[]] * (25 - data.length)
data.append('') # data[26] is word,freq from file
data.append(0) # data[27] is freq

# Loop over secondary memory file
while true
  data[25] = word_freqs.gets #  we read word,NNNN
  if data[25] == nil # EOF
    break
  end
  data[26] = data[25].split(',')[1].to_i # we split word,NNN and get NNN
  data[25] = data[25].split(',')[0].strip # word
  # check if this word has more counts than the ones in memory
  (0..25).each do |i|
    if data[i] == [] or data[i][1] < data[26]
      data.insert(i, [data[25], data[26]])
      data[26] = [] # del data[26]
      break
    end
  end
end

data[0...25].each do |tf|
  if tf.length == 2
    puts "#{tf[0]}-#{tf[1]}"
  end
end
word_freqs.close