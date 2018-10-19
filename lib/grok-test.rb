require 'logger'

require 'grok-pure'

class GrokTest
  PATTERNS_PATH = File.expand_path '..', File.dirname(__FILE__)

  class Error < StandardError

  end

  def self.logger=(logger)
    @logger = logger
  end
  def self.logger
    @logger ||= Logger.new(STDERR, Logger::UNKNOWN)
  end

  def logger
    self.class.logger
  end

  # @param path [String]
  def self.each_path(*paths, &block)
    for path in paths
      if File.directory? path
        Dir.glob(File.join(path, '*')) do |child_path|
           self.each_path(child_path, &block)
        end
      elsif File.exists? path
        yield path
      else
        raise Error, "No such file: #{path}"
      end
    end
  end

  def self.build(options)
    grok = Grok.new

    self.each_path(*options.pattern_paths) do |path|
      logger.info { "Load patterns from path: #{path}" }

      grok.add_patterns_from_file(path)
    end

    logger.debug { "Compile pattern: #{options.pattern}" }

    grok.compile(options.pattern,
      named_captures_only: options.named_captures_only,
    )

    new(grok)
  rescue Grok::PatternError => exc
    raise Error, "Invalid pattern #{options.pattern}: #{exc}"
  end

  def initialize(grok)
    @grok = grok
  end

  # @param pattern [String]
  # @param message [String]
  # @yield [key, value]
  # @raise [Error] no match
  def match(message)
    logger.debug { "Match message: #{message}" }

    match = @grok.match_and_capture(message) do |field, value|
      next if value.nil?

      yield field, value
    end

    logger.debug { "Message matched" }

    raise Error, "Message did not match #{@grok.pattern}: #{message}" unless match
  end

  # @param file [File]
  def test(file)
    for line in file
      puts "#{line}"

      match(line) do |field, value|
        puts "\t#{field}: #{value}"
      end

      puts
    end
  end
end
