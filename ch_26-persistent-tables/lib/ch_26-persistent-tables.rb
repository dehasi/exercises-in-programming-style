#!/usr/bin/env ruby
# frozen_string_literal: true

require 'sqlite3'

# The relational, database of this problem consists of 3 tables:
# documents, words, characters
def create_db_schema(connection)
  connection.execute 'CREATE TABLE documents (id INTEGER PRIMARY KEY AUTOINCREMENT, name)'
  connection.execute 'CREATE TABLE words (id, doc_id, value)'
  connection.execute 'CREATE TABLE characters (id, word_id, value)'
end

def load_file_into_database(path_to_file, connection)
  # Takes the path to a file and loads the contents into the database
  def _extract_words(path_to_file)
    str_data = File.read path_to_file
    word_list = str_data.gsub(/[\W_]+/, ' ').downcase.split
    stop_words = File.read('/Users/ravil/experimental/exips/stop_words.txt').split(',')
    stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars
    word_list.filter { |w| !stop_words.include? w }
  end

  words = _extract_words path_to_file

  # Now let's add data to the database
  # Add the document itself to the database
  connection.execute 'INSERT INTO documents (name) VALUES (?)', path_to_file
  result = connection.query 'SELECT id FROM documents WHERE name=?', path_to_file
  doc_id = result.next[0]

  # Add the words to the database
  result = connection.query 'SELECT MAX(id) FROM words'
  word_id = result.next[0]
  word_id = 0 if word_id.nil?

  words.each do |word|
    connection.execute 'INSERT INTO words (id, doc_id, value) VALUES (?, ?, ?)', word_id, doc_id, word
    # Add characters to the database
    char_id = 0
    word.chars.each do |char|
      connection.execute 'INSERT INTO  characters (id, word_id, value) VALUES (?, ?, ?)', char_id, word_id, char
      char_id += 1
    end
    word_id += 1
  end

end

# Create if it doesn't exist
unless File.exist? 'tf.db'
  connection = SQLite3::Database.open 'tf.db'
  create_db_schema(connection)
  load_file_into_database(ARGV[0], connection)
end

# Now, let's query

connection = SQLite3::Database.open 'tf.db'

result = connection.query ''\
  ' SELECT value, COUNT(*) as C'\
  ' FROM words'\
  ' GROUP BY value'\
  ' ORDER BY C DESC'

25.times do
  row = result.next
  puts "#{row[0]}-#{row[1]}"
end
