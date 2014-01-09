require 'test/unit'
if defined? require_relative
  require_relative 'reader_writer'
  require_relative '../lib/rwlock'
else
  require 'lib/rwlock'
  require 'test/reader_writer'
end
Thread.abort_on_exception = true
$DEBUG = true

class TestRWLock < Test::Unit::TestCase
  attr_reader :lock
  def setup
    @lock = RWLock.new
  end

  def test_lots_of_threads
    rw = ReaderWriter.new

    1000.times do |i|
      t = []
      10.times do
        t << Thread.new do
          lock.write_sync do
            rw.write
          end
        end
      end

      10.times do
        t << Thread.new do
          lock.read_sync do
            rw.read
          end
        end
      end

      5.times do
        t << Thread.new do
          lock.write_sync do
            rw.write
          end
        end
      end

      5.times do
        t << Thread.new do
          lock.read_sync do
            rw.read
          end
        end
      end

      t.each(&:join)

      assert_equal 0, rw.reading
      assert_equal 0, rw.writing
    end
  end

  def test_read_return_value
    assert_equal :hello, lock.read_sync { :hello }
  end

  def test_write_return_value
    assert_equal :hello, lock.write_sync { :hello }
  end

  def test_max_return_value
    assert_equal 10, lock.max

    lock = RWLock.new 100

    assert_equal 100, lock.max
  end
end
