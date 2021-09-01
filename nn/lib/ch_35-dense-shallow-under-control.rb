#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'

ASCII_LOWERCASE = 'abcdefghijklmnopqrstuvwxyz'.chars # Python's list(string.ascii_lowercase)
ASCII_UPPERCASE = ASCII_LOWERCASE.upcase

CHARACTERS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~ \t\n\r\x0b\x0c"
CHAR_INDICES = CHARACTERS.chars.each_with_index.map { |ch, i| [ch, i] }.to_h
INDICES_CHAR = CHARACTERS.chars.each_with_index.map { |ch, i| [i, ch] }.to_h

INPUT_VOCAB_SIZE = CHARACTERS.size

def encode_one_hot(line)
  x = Array.new(line.size, 0) { Array.new(INPUT_VOCAB_SIZE, 0) }
  line.chars.each_with_index do |c, i|
    index = if CHARACTERS.include? c
              CHAR_INDICES[c]
            else
              CHAR_INDICES[' ']
            end
    x[i][index] = 1
  end
  x
end

def decode_one_hot(x)
  x.map { |onehot| onehot.rindex(onehot.max) }
   .map { |one_index| INDICES_CHAR[one_index] }
   .join ''
end

def normalization_layer_set_weights(n_layer)
  wb = []
  w = Array.new(INPUT_VOCAB_SIZE, 0.0) { Array.new(INPUT_VOCAB_SIZE, 0.0) }
  b = Array.new(INPUT_VOCAB_SIZE, 0.0)
  # Let lower case letters go through
  # Let lower case letters go through
  ASCII_LOWERCASE.each do |c|
    i = CHAR_INDICES[c]
    w[i][i] = 1
  end
end

r = encode_one_hot("123")

puts decode_one_hot(encode_one_hot("0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~ \t\n\r\x0b\x0c"))
