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
  def test_lots_of_threads
    rw = ReaderWriter.new

    lock = RWLock.new

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
end
