#!/usr/bin/env ruby
# frozen_string_literal: true

CHARACTERS = '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ!"#$%&\'()*+,-./:;<=>?@[\\]^_`{|}~ \t\n\r\x0b\x0c'
# char_indices = dict((c, i) for i, c in enumerate(characters))
# indices_char = dict((i, c) for i, c in enumerate(characters))

INPUT_VOCAB_SIZE = CHARACTERS.size

ss = CHARACTERS.each_with_index { |item, index| [item, index] }.to_h
puts ss.inspect