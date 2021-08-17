#!/usr/bin/env ruby
# frozen_string_literal: true

$stops = File.open('/Users/ravil/experimental/exips/stop_words.txt').read.split(',') + 'abcdefghijklmnopqrstuvwxyz'.chars

# The database
$data = {}

# The internal functions of the "server"-side application
def error_state
  ['Something wrong', ['get', 'default', nil]]
end

# The "server"-side application handlers
default_get_handler = lambda { |args|
  rep = 'What you would like to do?'
  rep += "\n1 - Quit" + "\n2 - Upload file"
  links = { '1' => ['post', 'execution', nil], '2' => ['get', 'file_form', nil] }
  [rep, links]
}

quit_handler = lambda { |args|
  warn 'Goodbye cruel world...'
  exit 1
}

upload_get_handler = ->(args) { ['Name of file to upload', ['post', 'file']] }

upload_post_handler = lambda { |args|
  warn "upload_post_handler #{args.inspect}"
  def create_data(fn)
    if $data.include? fn
      return
    end
    word_freqs = File.read(fn).downcase
                     .scan(/[a-z]{2,}/)
                     .filter { |w| !$stops.include? w }
                     .group_by(&:itself)
                     .transform_values(&:size)

    $data[fn] = word_freqs.sort_by { |p| p[1] }.reverse
  end

  if args.nil?
    return error_state
  end
  filename = args[0]
  begin
    create_data filename
  rescue StandardError => e
    warn "Unexpected error: #{e}"
    return error_state
  end
  $word_get_handler.call [filename, 0]
}

$word_get_handler = lambda { |args|
  def get_word(filename, word_index)
    if word_index < $data[filename].size
      $data[filename][word_index]
    else
      ['no more words', 0]
    end
  end

  filename = args[0]; word_index = args[1]
  word_info = get_word(filename, word_index)

  rep = "\n#{word_index + 1}: #{word_info[0]} - #{word_info[1]}"

  rep += "\n\nWhat would you like to do next?"
  rep += "\n1 - Quit" + "\n2 - Upload file"
  rep += "\n3 - See the most frequently occurring word"
  links = { '1' => ['post', 'execution', nil],
            '2' => ['get', 'file_form', nil],
            '3' => ['get', 'word', [filename, word_index + 1]] }
  [rep, links]
}

# Handler registration
$handlers = { 'post_execution' => quit_handler,
              'get_default' => default_get_handler,
              'get_file_form' => upload_get_handler,
              'post_file' => upload_post_handler,
              'get_word' => $word_get_handler }

# The "server" core
def handle_request(verb, uri, args)
  warn "handle_request #{verb}, #{uri}, #{args}"

  def handler_key(verb, uri)
    "#{verb}_#{uri}"
  end

  if $handlers.include? handler_key(verb, uri)
    $handlers[handler_key(verb, uri)].call(args)
  else
    $handlers[handler_key('get', 'default')].call(args)
  end
end

# A very simple client "browser"
def render_and_get_input(state_representation, links)
  puts state_representation; STDOUT.flush
  case links
  when Hash # many possible next states
    input = gets.chomp.strip.to_s
    if links.include? input
      links[input]
    else
      ['get', 'default', nil]
    end
  when Array
    if links[0] == 'post' # get "form" data
      input = gets.chomp.strip
      links.append([input])
    end
    links
  else
    ['get', 'default', nil]
  end
end

request = ['get', 'default', nil]

while true
  # "server"-side computation
  state_representation, links = handle_request(*request)
  # "client"-side computation ; /Users/ravil/experimental/exips/test/pride-and-prejudice-input.txt
  request = render_and_get_input(state_representation, links)
end
