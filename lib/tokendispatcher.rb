require 'tokendispatcher/datastruct/fixed_length_queue'
require 'tokendispatcher/datastruct/lru_cache'
module TokenDispatcher
  module TokenServer
    def post_init
      puts "-- someone connected to the echo server!"
    end

    def receive_data data
      send_data ">>>you sent: #{data}"
      close_connection if data =~ /quit/i
    end

    def unbind
      puts "-- someone disconnected from the echo server!"
    end
  end
end
