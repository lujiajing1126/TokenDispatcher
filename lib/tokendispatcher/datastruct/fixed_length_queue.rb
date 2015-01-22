require 'uuid'
module TokenDispatcher
  module DataStruct
    class Queue
      SUCCESS = 127
      FAIL = -1
      MAX_SECONDS = 600
      def initialize(size)
        @max_size = size
        @uuid = UUID.new
        regenerate
      end

      # fetch the value which in the last position
      def fetch
        if @queue.length > 0
          uuid = @queue.pop
          if expired? uuid
            delete uuid
            FAIL.to_s
          else
            uuid
          end
        else
          generate
          fetch
        end
      end

      def valid?(uuid)
        is_valid = @queue.index(uuid) && !expired?(uuid)
        if is_valid
          true
        else
          delete uuid
          false
        end
      end

      def is_used?(uuid)
        valid? and @is_used.index uuid ? true : false
      end

      # put the value into the first position of Queue
      def put(uuid)
        if @queue.length < @max_size
          if has? uuid
            if expired? uuid
              delete uuid
              put uuid
            else
              FAIL.to_s
            end
          else
            @queue.unshift uuid
            @expires[obj.to_s.to_sym] = Time.now.to_i
            SUCCESS.to_s
          end
        else
          FAIL.to_s
        end
      end

      def putback(uuid)
        if @queue.length < @max_size
          @queue.unshift uuid
          SUCCESS.to_s
        else
          FAIL.to_s
        end
      end

      # delete from Queue
      def delete(uuid)
        index = @queue.index(uuid)
        @expires.delete uuid.to_sym
        if index
          @queue.delete_at index
          @expires.delete uuid.to_sym
          generate
          SUCCESS
        else
          @expires.delete uuid.to_sym
          FAIL
        end
      end

      #
      def delete!(uuid)

      end

      # clean expired keys and uniq keys
      def clean
        @expires.each do |k,v|
          if (index = @queue.index(k.to_s)) != nil
            unless (Time.now.to_i - v) < MAX_SECONDS
              @queue.delete_at index
              @expires.delete k
            end
          else
            @expires.delete k
          end
        end
        @queue.uniq!
        generate
      end

      # use uuid in non-login status
      def use!(uuid)
        notate uuid
      end

      # take uuid into login-status pool
      def recycle!(uuid)
        delete uuid
        generate
      end

      private
      def has?(uuid)
        @queue.index uuid ? true : false
      end

      # notate
      def notate uuid

      end

      def add

      end

      def generate
        while @queue.length < @max_size
          put @uuid.generate
        end
      end

      def expired?(uuid)
        (Time.now.to_i - @expires[uuid.to_sym]) < MAX_SECONDS ? false : true
      end

      def regenerate
        @queue = []
        @expires = {}
        @is_used = []
        generate
      end
    end
  end
end
