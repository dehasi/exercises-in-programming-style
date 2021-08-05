#!/usr/bin/env ruby

# As Ruby doesn't have an idiomatic assert, I wrote my own
def assert(condition, msg = 'Assertion failed!')
  raise msg unless condition
end

module AcceptTypeDecorator

  # it's called when a method is being declared.
  # if 'wrap' was called before, then decorator_methods is not empty
  # therefore we update an original method name to "#{method_name}_without_decorator"
  # and define a method that calls a decorator which wraps an original method
  # and it works recursively
  def method_added(method_name)
    super
    warn "call method_added(#{method_name}); decorator_methods=#{decorator_methods.inspect}"
    return if decorator_methods.empty?

    decorator_method = decorator_methods.pop
    decorator_type = decorator_accepted_types.pop
    new_name = "#{method_name}_without_decorator"

    alias_method new_name, method_name

    define_method method_name do |*args|
      method(decorator_method).call decorator_type, method(new_name), *args do |p = args|
        method(new_name).call(*p)
      end
    end

  end

  def wrap(decorator, type)
    decorator_methods << decorator
    if type.is_a?(Array)
      decorator_accepted_types << type
    else
      decorator_accepted_types << [type]
    end
  end

  def decorator_methods
    @decorator_methods ||= []
  end

  def decorator_accepted_types
    @decorator_accepted_types ||= []
  end
end

class Program
  extend AcceptTypeDecorator

  def accept_type(types, method, *args)
    (0...args.length).each do |i|
      unless args[i].instance_of?(types[i])
        raise TypeError, "Expecting #{types[i]} on position #{i} but got #{args[i].class} for method #{method.original_name}"
      end
    end
    yield
  end

  wrap :accept_type, String

  def extract_words(path_to_file)
    word_list = File.read(path_to_file).gsub(/[\W_]+/, ' ').downcase.split

    stop_words = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',')
    stop_words += 'abcdefghijklmnopqrstuvwxyz'.chars

    word_list.filter { |w| !stop_words.include? w }
  end

  wrap :accept_type, Array

  def frequencies(word_list)
    word_freqs = Hash.new(0)
    word_list.each { |w| word_freqs[w] += 1 }
    word_freqs
  end

  wrap :accept_type, Hash

  def sort(word_freqs)
    word_freqs.sort_by { |p| p[1] }.reverse
  end

end

program = Program.new

word_freqs = program.sort program.frequencies program.extract_words ARGV[0]
word_freqs.first(25).each { |(w, c)| puts "#{w}-#{c}" }
