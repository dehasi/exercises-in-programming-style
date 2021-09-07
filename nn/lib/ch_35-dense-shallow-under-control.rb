#!/usr/bin/env ruby
# frozen_string_literal: true

require 'tensorflow'
require 'matrix'

ASCII_LOWERCASE = 'abcdefghijklmnopqrstuvwxyz'.chars # Python's list(string.ascii_lowercase)
ASCII_UPPERCASE = ASCII_LOWERCASE.map(&:upcase)
ASCII_LETTERS = ASCII_LOWERCASE + ASCII_UPPERCASE
CHARACTERS = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!\"#$%&'()*+,-./:;<=>?@[\\]^_`{|}~ \t\n\r\x0b\x0c"
CHAR_INDICES = CHARACTERS.chars.each_with_index.map { |ch, i| [ch, i] }.to_h
INDICES_CHAR = CHARACTERS.chars.each_with_index.map { |ch, i| [i, ch] }.to_h

INPUT_VOCAB_SIZE = CHARACTERS.size

def encode_one_hot(line)
  x = Array.new(line.size) { Array.new(INPUT_VOCAB_SIZE, 0) }
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
  w = Matrix.build(INPUT_VOCAB_SIZE, INPUT_VOCAB_SIZE) { 0 }
  b = Array.new(INPUT_VOCAB_SIZE, 0.0)
  # Let lower case letters go through
  # Let lower case letters go through
  ASCII_LOWERCASE.each do |c|
    i = CHAR_INDICES[c]
    w[i, i] = 1
  end

  # Map capitals to lower case
  ASCII_UPPERCASE.each do |c|
    i = CHAR_INDICES[c]
    il = CHAR_INDICES[c.downcase]
    w[i, il] = 1
  end
  # Map all non-letters to space
  sp_idx = CHAR_INDICES[' ']
  CHARACTERS.chars.filter { |c| !ASCII_LETTERS.include?(c) }.each do |c|
    i = CHAR_INDICES[c]
    w[i, sp_idx] = 1
  end
  wb.append(w)
  wb.append(b)
  # n_layer << (wb) # n_layer.set_weights(wb) | weight, bias
  # return n_layer
  wb
end

module CH35
  class Sequential
    attr_reader :layers

    def initialize
      @layers = []
    end

    def add(layer)
      @layers << layer
    end

    def predict(input)
      # activation(dot(input, kernel) + bias)
      weights = layers[0][0]
      bias = layers[0][1]
      input = to_matrix(input)

      ww = (input * weights).to_a

      (0...ww.size).each do |i|
        ww[i] = softmax(sum(ww[i], bias))
      end
      ww
    end

    def dot(m1, m2)
      result = Array.new(m1.size) { Array.new(m2[0].size, 0) }
      (0...result.size).each do |i|
        (0...result.size).each do |j|
          (0...m1[0].size).each do |k|
            result[i][j] += m1[i][k] * m2[k][j]
          end
        end
      end
      result
    end

    def sum(arr1, arr2)
      result = Array.new(arr1.size, 0)
      (0...arr1.size).each do |i|
        result[i] = arr1[i] + arr2[i]
      end
      result
    end

    def softmax(array)
      exps = array.map { |x| Math.exp(x) }
      k = exps.sum
      result = []
      (0...array.size).each do |i|
        result << exps[i] / k
      end
      result
    end

    def to_matrix(array)
      Matrix.build(array.size, array[0].size) { |row, col| array[row][col] }
    end
  end
end

def build_model
  CH35::Sequential.new
end

model = build_model
model.add(normalization_layer_set_weights(nil))
normalization_layer_set_weights model.layers[0]
# puts model.layers.inspect

File.readlines(ARGV[0]).each do |line|
  next if line.strip.empty?

  batch = encode_one_hot(line)
  preds = model.predict(batch)
  normal = decode_one_hot(preds)
  puts normal
end
