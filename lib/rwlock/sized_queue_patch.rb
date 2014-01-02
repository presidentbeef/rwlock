if not SizedQueue.instance_methods(false).include? :clear
  if RUBY_VERSION == "1.9.3"
    class SizedQueue
      # Removes all objects from the queue and wakes waiting threads, if any.
      def clear
        @mutex.synchronize do
          @que.clear
          begin
            until @queue_wait.empty?
              @queue_wait.shift.wakeup
            end
          rescue ThreadError
            retry
          end
        end
      end
    end
  elsif RUBY_VERSION == "2.0.0"
    class SizedQueue
      # Removes all objects from the queue and wakes waiting threads, if any.
      def clear
        @mutex.synchronize do
          @que.clear
          @enque_cond.signal
        end
      end
    end
  end
end
