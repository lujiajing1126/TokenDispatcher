require 'uuid'
module TokenDispatcher
  module DataStruct
    class Queue
      SUCCESS = 127
      FAIL = -1
      MAX_SECONDS = 600
      LOCK_SECONDS = 300
      RESIZE_RATE = 0.8
      THRESHOLD = 0.9
      LOWER_THRESHOLD = 0.5
      EXPIRED = "EXPIRED"
      LOCKED = "CAPTCHA"
      INVALID = "INVALID"
      EXHAUSTED = "EXHAUSTED"
      def initialize(size)
        @default_size = @max_size = size
        @uuid = UUID.new
        regenerate
      end

      # fetch the value which in the last position
      # if queue length > 0, return uuid
      # if expired, return uuid
      # if length <= 0, fill the queue and fetch
      def fetch
        if @queue.length > 0
          uuid = @queue.pop
          @queue.unshift uuid if @queue.length < @max_size
          if expired? uuid
            fetch
          elsif locked? uuid
            fetch
          else
            uuid
          end
        else
          EXHAUSTED
        end
      end

      # check whether the uuid is valid
      # or NOT_FOUND/EXPIRED/LOCKED
      def is_valid(uuid)
        unless has? uuid
          return INVALID
        end
        if expired? uuid
          return EXPIRED
        end
        if locked? uuid
          return LOCKED
        end
        true
      end

      # clean one expired key and add one to avoid overflow bug
      def check
        puts 'checking status'
        expired = 0
        locked = 0
        added = 0
        @expires.each do |key,_|
          if expired? key.to_s
            delete! key.to_s
            add!
            ++ expired
            ++ added
          end
        end

        @is_locked.each do |value|
          if expired_lock? value
            delete! value.split('%')[0]
            add!
            ++ locked
            ++ added
          end
        end

        puts "ExpiredKey:#{expired};LockedKey:#{locked};AddedKeys:#{added}"
        # if @is_locked.length > (THRESHOLD * @max_size).to_i
        #   resize
        #   regenerate
        # end
        #
        # if @is_locked.length < (@max_size * LOWER_THRESHOLD).to_i
        #   resume
        #   regenerate
        # end
      end

      private
      def has?(uuid)
        @queue.index uuid ? true : false
      end

      def expired_lock?(uuid_key)
        lock_time = uuid_key.split('%')[1].to_i
        (Time.now.to_i - lock_time > LOCK_SECONDS) ? true : false
      end

      def expired?(uuid)
        (Time.now.to_i - @expires[uuid.to_sym]) < MAX_SECONDS ? false : true
      end

      def locked?(uuid)
        @is_locked.index(uuid) ? true : false
      end

      def lock!(uuid)
        @is_locked << "#{uuid}%#{Time.now.to_i}" unless @is_locked.index uuid
      end

      def add!
        uuid = @uuid.generate.to_s
        @queue.unshift uuid
        @expires[uuid.to_sym] = Time.now.to_i
      end

      def fill!
        while @queue.length < @max_size
          add!
        end
      end

      # delete from Queue unless in use
      def delete!(uuid)
        index = @queue.index uuid
        index_locked = @is_locked.index uuid
        if index
          @queue.delete_at index
        end
        if index_locked
          @is_locked.delete_at index_locked
        end
        @expires.delete uuid.to_sym
      end

      def resize
        @max_size = (@max_size * RESIZE_RATE).to_i
      end

      def resume
        @max_size = @default_size
      end

      def regenerate
        @queue = []
        @expires = {}
        @is_locked = []
        fill!
      end
    end
  end
end
