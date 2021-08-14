#!/usr/bin/env ruby
# frozen_string_literal: true

# Models the data. In this case, we're only interested
# in words and their frequencies as an end result
class WordFrequencyModel
  attr_reader :freqs

  def initialize(path_to_file)
    @freqs = {}
    @stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
    update path_to_file
  end

  def update(path_to_file)
    words = File.read(path_to_file).downcase.scan(/[a-z]{2,}/)
    @freqs = words.filter { |word| !@stop_words.include? word }
                  .group_by(&:itself)
                  .transform_values(&:size)
  end
end

class WordFrequencyView

  def initialize(model)
    @model = model
  end

  def render
    sorted_freqs = @model.freqs.sort_by { |p| p[1] }.reverse
    sorted_freqs.first(25).each { |(w, c)| puts "#{w}-#{c}" }
  end
end

class WordFrequencyController
  def initialize(model, view)
    @model, @view = model, view
    @view.render
  end

  def run
    loop do
      puts 'Next file:'
      $stdout.flush
      filename = $stdin.gets.strip
      @model.update filename
      @view.render
    end
  end
end

model = WordFrequencyModel.new ARGV[0]
view = WordFrequencyView.new model
controller = WordFrequencyController.new model, view
# controller.run #/Users/ravil/experimental/exips/test/pride-and-prejudice-input.txt
