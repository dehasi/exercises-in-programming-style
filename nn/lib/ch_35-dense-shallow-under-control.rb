#!/usr/bin/env ruby
# frozen_string_literal: true

require 'matrix'

CHARACTERS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~ \t\n\r\x0b\x0c"
CHAR_INDICES = CHARACTERS.chars.each_with_index.map { |ch, i| [ch, i] }.to_h
INDICES_CHAR = CHARACTERS.chars.each_with_index.map { |ch, i| [i, ch] }.to_h

INPUT_VOCAB_SIZE = CHARACTERS.size

def encode_one_hot(line)
  x = Matrix.build(line.size, INPUT_VOCAB_SIZE) { 0 }
  line.chars.each_with_index do |c, i|
    if CHARACTERS.include? c
      index = CHAR_INDICES[c]
    else
      index = CHAR_INDICES[' ']
    end
    x[i, index] = 1
  end
  x
end

r = encode_one_hot("123")
puts r.inspect
