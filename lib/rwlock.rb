require 'thread'
if defined? require_relative
  require_relative 'rwlock/sized_queue_patch'
else
  require File.join(File.expand_path(File.dirname(__FILE__)), "rwlock", "sized_queue_patch")
end

# This class provides a simple readers-writer lock (RWLock).
# A RWLock allows multiple "readers" to access a resource simultaneously
# but "writers" must have exclusive access. In other words, during a "write"
# only a single thread may have access to the resource.
#
# This RWLock prevents writer starvation. While there are no hard guarantees,
# if a writer requests access it will generally get access as soon as all
# current readers are finished.
#
# When the current writer is finished, waiting readers have first opportunity
# to grab the lock. This should result in no starvation of either readers nor
# writers, although access may not be "fair".
class RWLock
  # Creates new readers-writers lock.
  # The `max_size` argument limits how many readers may read simultaneously.
  # A limit is necessary to prevent writer starvation.
  def initialize max_size = 10
    @write_lock = Mutex.new
    @q = SizedQueue.new(max_size)
  end

  # Obtains reading lock and executes block, then releases reading lock.
  # Many calls to RWLock#read_sync may execute in parallel, but wil not
  # overlap with calls to RWLock#write_sync.
  #
  # If the number of readers is currently at the maximum or a write operation
  # is in progress, this method will wait. When a reading spot is available and
  # no write operations are occurring, then the block will be executed.
  #
  #     rwl = RWLock.new
  #     a = [1, 2, 3]
  #
  #     Thread.new do
  #       rwl.read_sync do
  #         puts a[1]
  #       end
  #     end
  def read_sync
    @q.push true
    yield
  ensure
    @q.pop
  end

  # Obtains writing lock and executes block, then releases writing lock.
  # The block will have exclusive access to the lock, with no readers or
  # other writers allowed to execute at the same time.
  #
  # If any readers are executing, the method will wait until the current
  # readers are finished then the block will be executed.
  #
  # If another writer is executing, the method will wait until the current
  # writer is finished. However, readers have first chance at access after a
  # write.
  #
  #     rwl = RWLock.new
  #     a = [1, 2, 3]
  #
  #     Thread.new do
  #       rwl.write_sync do
  #         a[1] += 1
  #       end
  #     end
  def write_sync
    @write_lock.synchronize do
      @q.max.times { @q.push true }

      begin
        yield
      ensure
        @q.clear
      end
    end
  end

  # Returns the set maximum number of simultaneous readers.
  def max
    @q.max
  end
end
