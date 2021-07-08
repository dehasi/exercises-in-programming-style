#!/usr/bin/env ruby

# The "I'll call you back" Word Frequency Framework

class WordFrequencyFramework

  def register_for_load_event(handler)
    @load_event_handlers.append(handler)
  end

  def register_for_dowork_event(handler)
    @dowork_event_handlers.append(handler)
  end

  def register_for_end_event(handler)
    @end_event_handlers.append(handler)
  end

  def run(path_to_file)
    for h in @load_event_handlers
      h.call(path_to_file)
    end

    for h in @dowork_event_handlers
      h.call()
    end

    for h in @end_event_handlers
      h.call()
    end
  end
end

# The entities of the application
class DataStorage

  def initialize(wfapp, stop_words_filter)
    @stop_words_filter = stop_words_filter
    wfapp.register_for_load_event(-> { load })
    wfapp.register_for_dowork_event(-> { produce_words })
  end

  def load()
    @data = File.read(path_to_file).gsub(/[\W_]+/, ' ').downcase.split
  end

  def produce_words()
    for w in @data.split
      if not @stop_words_filter.stop_word? w
        for h in @word_even_handlers
          h.call(w)
        end
      end
    end
  end

  def regirster_for_word_event(handler)
    @word_even_handlers.append(handler)
  end
end