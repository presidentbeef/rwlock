## RWLock - Simple Readers-Writer Lock

A readers-writer lock allows multiple readers to access a resource at once,
but writers get exclusive access.
This is useful, for example, when a resource needs to be updated atomically
but is safe to be read by multiple concurrent threads.

This library provides thread-level locking.

### Compatibility

RWLock should work with:

* MRI 1.8.7
* MRI 1.9.3 (with monkey patch)
* MRI 2.0.0 (with monkey patch)
* JRuby

Does not with with:

* MRI 2.1.0 due to [bug in SizedQueue#push](http://bugs.ruby-lang.org/issues/9302)

Monkey patches are provided for MRI 1.9.3 and 2.0.0 because SizedQueue#clear [also has a bug](https://bugs.ruby-lang.org/issues/9342).
### Usage

```ruby
require 'rwlock'

# Create new RWLock with 15 concurrent readers. Default is 10
rwl = RWLock.new(15)  

# Safely perform some read/nonmutating operation
rwl.read_sync do
  # read some stuff
end

# Safely perform some write/destructive operation
rwl.write_sync do
  # write some stuff
end
```

Normally, of course, read/write operations would be performed in threads.

### Example

Safely updating an array with multiple readers:

```ruby
require 'rwlock'

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
```

Note: you can definitely get some `OMG HAX` if example is run with JRuby without RWLock. MRI tends to have more accidental thread safety in it.

### License

MIT - see MIT-LICENSE file
