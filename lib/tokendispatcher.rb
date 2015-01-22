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
      if data.to_s.strip == 'fetch'
        fetch_obj = @queue.fetch
        send_data fetch_obj
      elsif data.to_s.strip == 'status'
        fetch_obj = @queue.status
        send_data fetch_obj
      elsif data.to_s.strip == 'check'
        fetch_obj = @queue.check
        send_data fetch_obj
      elsif data.to_s.strip =~ /^lock/
        uuid = data.to_s.strip.split(':')[1]
        @queue.lock! uuid
        send_data uuid
      end
    end

    def unbind
      puts "-- someone disconnected from the echo server!"
    end
  end
end
