module TokenDispatcher
  module DataStruct
    class Queue
      SUCCESS = 127
      FAIL = -1
      def initialize(size)
        @max_size = size
        @queue = []
      end
      def fetch
        if @queue.length > 0
          @queue.pop
        else
          FAIL.to_s
        end
      end
      def put(obj)
        if @queue.length < @max_size
          @queue.unshift obj
          SUCCESS.to_s
        else
          FAIL.to_s
        end
      end
    end
  end
end
