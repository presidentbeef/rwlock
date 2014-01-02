require_relative '../lib/rwlock'

# Note: doesn't protect contents from mutation
class SafeArrayUpdate
  def initialize *args
    @a = args
    @l = RWLock.new
  end

  def [] index
    @l.read_sync do
      @a[index]
    end
  end

  def []= index, value
    @l.write_sync do
      @a[index] = value
    end
  end
end

sau = SafeArrayUpdate.new(1, 2, 3)

readers = 10.times.map do
  Thread.new do
    abort "OMG HAX" unless sau[1] == sau[1]
  end
end

writers = 5.times.map do
  Thread.new do
    sau[1] += 1
  end
end

readers.each(&:join)
writers.each(&:join)

abort "OMG HAX" unless sau[1] == 7
