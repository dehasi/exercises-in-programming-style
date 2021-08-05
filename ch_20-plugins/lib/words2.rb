def extract_words(path_to_file)
  stops = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
  File.read(path_to_file).downcase.scan(/[a-z]{2,}/).filter { |w| !stops.include? w }
end

def word_version
  'words2'
end
