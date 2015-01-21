require 'tokendispatcher/datastruct/fixed_length_queue'
require 'tokendispatcher/datastruct/lru_cache'
require 'eventmachine'
module TokenDispatcher
  class TokenServer < EventMachine::Connection
    def initialize(queue)
      @queue = queue
    end

    def post_init
      puts "-- someone connected to the echo server!"
    end

    def receive_data data
      if data == "fetch"
        send_data(@queue.fetch)
      else
        send_data(@queue.put(data))
      end
    end

    def unbind
      puts "-- someone disconnected from the echo server!"
    end
  end
end
