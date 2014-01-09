Gem::Specification.new do |s|
  s.name = "rwlock"
  s.version = "0.0.1"
  s.authors = ["Justin Collins"]
  s.summary = "Simple readers-writer lock."
  s.description = "Simple thread-level readers-writer lock in pure Ruby. Allows multiple readers to access a resource while writers get exclusive access."
  s.homepage = "https://github.com/presidentbeef/rwlock"
  s.files = Dir["lib/**/*"]
  s.license = "MIT"
end
