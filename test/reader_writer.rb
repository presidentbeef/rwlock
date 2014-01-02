class ReaderWriter
  attr_reader :writing, :reading

  def initialize
    @writing = 0
    @reading = 0
    @r = Mutex.new
  end

  def write
    @writing += 1
    not_both
    sleep rand(1)
    not_both
  ensure
    @writing -= 1 
  end

  def read
    @r.synchronize do
      @reading += 1
    end
    not_both
    sleep rand(1)
    not_both
  ensure
    @r.synchronize do
      @reading -= 1
    end
  end

  def not_both
    if @writing > 0 and @reading > 0
      raise "OMG #@writing and #@reading"
    elsif @writing > 1
      raise "OMG #@writing writing"
    elsif @reading > 10
      raise "OMG #@reading reading"
    end
  end
end

