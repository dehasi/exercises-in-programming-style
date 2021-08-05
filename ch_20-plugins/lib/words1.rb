
def extract_words(path_to_file)
  str_data = File.read path_to_file
  word_list = str_data.gsub(/[\W_]+/, ' ').downcase.split
  stop_words = File.read('/Users/ravil/experimental/exips/stop_words.txt').split(',')
  stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
  word_list.filter { |w| !stop_words.include? w }
end

def word_version
  'words1'
end
