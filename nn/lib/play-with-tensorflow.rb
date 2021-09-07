#!/usr/bin/env ruby
# frozen_string_literal: true

require 'tensorflow'

a = Tf.constant([1, 2, 3])
b = Tf.constant([4, 5, 6])
c = a + b
puts c.inspect

v = Tf::Variable.new(0.0)
w = v + 1

puts w

puts Tf::Math.abs([-1, -2])
puts Tf::Math.sqrt([1.0, 4.0, 9.0])

def fizzbuzz(max_num)
  max_num.times do |i|
    num = Tf.constant(i + 1)
    if (num % 3).to_i == 0 && (num % 5).to_i == 0
      puts "FizzBuzz"
    elsif (num % 3).to_i == 0
      puts "Fizz"
    elsif (num % 5).to_i == 0
      puts "Buzz"
    else
      puts num.to_i
    end
  end
end


mnist = Tf::Keras::Datasets::MNIST
(x_train, y_train), (x_test, y_test) = mnist.load_data
x_train = x_train / 255.0
x_test = x_test / 255.0

model = Tf::Keras::Models::Sequential.new([
                                            Tf::Keras::Layers::Flatten.new(input_shape: [28, 28]),
                                            Tf::Keras::Layers::Dense.new(128, activation: "relu"),
                                            Tf::Keras::Layers::Dropout.new(0.2),
                                            Tf::Keras::Layers::Dense.new(10, activation: "softmax")
                                          ])

model.compile(optimizer: "adam", loss: "sparse_categorical_crossentropy", metrics: ["accuracy"])
model.fit(x_train, y_train, epochs: 5)
model.evaluate(x_test, y_test)

puts model
puts "ge"
