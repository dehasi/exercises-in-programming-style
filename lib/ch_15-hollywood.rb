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