# frozen_string_literal: true

module Application
  # Expires in 60 sec.
  # cache.get(:'key-for-cache', lifetime: 60) do
  #   slow code here
  # end
  class Cached
    # Makes a new object of the cache.
    #
    # "sync" is whether the hash is thread-safe (`true`)
    # or not (`false`); it is recommended to leave this parameter untouched,
    # unless you really know what you are doing.
    #
    # If the <tt>dirty</tt> argument is set to <tt>true</tt>, a previously
    # calculated result will be returned if it exists and is already expired.
    def initialize(sync: true, dirty: false)
      @hash = {}
      @sync = sync
      @dirty = dirty
      @mutex = Mutex.new
    end

    # Total number of keys currently in cache.
    def size
      @hash.size
    end

    # Gets the value from the cache by the provided key.
    #
    # If the value is not
    # found in the cache, it will be calculated via the provided block. If
    # the block is not given, an exception will be raised (unless <tt>dirty</tt>
    # is set to <tt>true</tt>). The lifetime
    # must be in seconds. The default lifetime is huge, which means that the
    # key will never be expired.
    #
    # If the <tt>dirty</tt> argument is set to <tt>true</tt>, a previously
    # calculated result will be returned if it exists and is already expired.
    def get(key, lifetime: 300, dirty: false, &block)
      if block_given?
        if (dirty || @dirty) && locked? && expired?(key) && @hash.key?(key)
          return @hash[key][:value]
        end
        synchronized { calc(key, lifetime, &block) }
      else
        rec = @hash[key]
        if expired?(key)
          return rec[:value] if dirty || @dirty

          @hash.delete(key)
          rec = nil
        end
        raise 'The key is absent in the cache' if rec.nil?

        rec[:value]
      end
    end

    # Checks whether the value exists in the cache by the provided key. Returns
    # TRUE if the value is here. If the key is already expired in the hash,
    # it will be removed by this method and the result will be FALSE.
    def exists?(key, dirty: false)
      rec = @hash[key]
      if expired?(key) && !dirty && !@dirty
        @hash.delete(key)
        rec = nil
      end
      !rec.nil?
    end

    # Checks whether the key exists in the cache and is expired. If the
    # key is absent FALSE is returned.
    def expired?(key)
      rec = @hash[key]
      !rec.nil? && rec[:start] < Time.now - rec[:lifetime]
    end

    # Returns the modification time of the key, if it exists.
    # If not, current time is returned.
    def mtime(key)
      rec = @hash[key]
      rec.nil? ? Time.now : rec[:start]
    end

    # Is cache currently locked doing something?
    def locked?
      @mutex.locked?
    end

    # Put a value into the cache.
    def put(key, value, lifetime: 2**32)
      synchronized do
        @hash[key] = {
          value: value,
          start: Time.now,
          lifetime: lifetime
        }
      end
    end

    # Removes the value from the hash, by the provied key. If the key is absent
    # and the block is provided, the block will be called.
    def remove(key)
      synchronized { @hash.delete(key) { yield if block_given? } }
    end

    # Remove all keys from the cache.
    def remove_all
      synchronized { @hash = {} }
    end

    # Remove all keys that match the block.
    def remove_by
      synchronized do
        @hash.each_key do |k|
          @hash.delete(k) if yield(k)
        end
      end
    end

    # Remove keys that are expired.
    def clean
      synchronized { @hash.delete_if { |key, _value| expired?(key) } }
    end

    private

    def calc(key, lifetime)
      rec = @hash[key]
      rec = nil if expired?(key)
      if rec.nil?
        @hash[key] = {
          value: yield,
          start: Time.now,
          lifetime: lifetime
        }
      end
      @hash[key][:value]
    end

    def synchronized
      if @sync
        @mutex.synchronize do
          # I don't know why, but if you remove this line, the tests will
          # break. It seems to me that there is a bug in Ruby. Let's try to
          # fix it or find a workaround and remove this line.
          sleep 0.00001
          yield
        end
      else
        yield
      end
    end
  end
end
