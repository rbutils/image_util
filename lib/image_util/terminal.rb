# frozen_string_literal: true

require "io/console"

module ImageUtil
  module Terminal
    module_function

    def detect_support(termin, termout)
      return [] if !termin.tty? || !termout.tty?
      
      supported = termout.instance_variable_get(:@imageutil_support_cache)
      return supported if supported

      supported = [:tty]

      # Send kitty query
      query_terminal(termin, termout, "\e_Gi=31,s=1,v=1,a=q,t=d,f=24;AAAA\e\\\e[c".b) do |resp|
        resp.start_with?("\e_G".b) && resp.include?("OK".b)
      end and supported << :kitty

      # Send sixel query
      query_terminal(termin, termout, "\e[?2;1;0S".b) do |resp|
        resp.include?("\e[?2;0;".b)
      end and supported << :sixel

      termout.instance_variable_set(:@imageutil_support_cache, supported)
    end

    def query_terminal(termin, termout, query, timeout = 0.2)
      resp = ""
      termin.raw do
        termout.write query
        termout.flush
        t0 = Time.now
        loop do
          begin
            resp += termin.read_nonblock(512)
            break if resp.start_with?("\e".b)
          rescue IO::WaitReadable
            IO.select([termin], nil, nil, timeout)
          end
          break if Time.now - t0 > timeout
        end
      end
      yield resp
    rescue EOFError, Errno::EBADF
      false
    end

    def output_image(termin, termout, image)
      support = detect_support(termin, termout)

      if support.include? :kitty
        image.to_string(:kitty)
      elsif support.include? :sixel
        image.to_string(:sixel)
      end
    end
  end
end
