require "coverage"
require "digest/md5"

require "oneshot_coverage/logger/null_logger"
require "oneshot_coverage/railtie" if defined?(Rails)

module OneshotCoverage
  class Middleware
    def initialize(app)
      @app = app
    end

    def call(env)
      @app.call(env)
    ensure
      if Coverage.running?
        OneshotCoverage.emit
      end
    end
  end

  class Reporter
    def initialize(target_path:, logger:, max_emit_at_once:)
      @target_path = target_path
      @logger = logger
      @buffer = []
      @max_emit_at_once = max_emit_at_once
      if defined?(Bundler)
        @bundler_path = Bundler.bundle_path.to_s
      end
    end

    def emit
      Coverage.result(clear: true, stop: false).
        select { |k, v| is_target?(k, v) }.
        flat_map { |k, v| transform(k, v) }.
        each { |row| @buffer << row }

      @buffer.shift(emit_at_once).each do |row|
        # Retry when fail to post
        unless @logger.post(row)
          @buffer << row
        end
      end
    end

    def is_target?(filepath, value)
      return false if value[:oneshot_lines].empty?
      return false if !filepath.start_with?(@target_path)
      return false if @bundler_path && filepath.start_with?(@bundler_path)
      true
    end

    def transform(filepath, value)
      rel_path = filepath[@target_path.size..-1]
      md5_hash =
        if md5_hash_cache.key?(filepath)
          md5_hash_cache[filepath]
        else
          md5_hash_cache[filepath] = Digest::MD5.file(filepath).hexdigest
        end

      value[:oneshot_lines].map do |line|
        {
          path: rel_path,
          md5_hash: md5_hash,
          lineno: line
        }
      end
    end

    def md5_hash_cache
      @md5_hash_cache ||= {}
    end

    def emit_at_once
      @max_emit_at_once || @buffer.size
    end
  end

  module_function

  def start
    Coverage.start(oneshot_lines: true)

    # To handle execution with exit immediatly
    at_exit do
      OneshotCoverage.emit
    end
  end

  def emit
    @reporter&.emit
  end

  def configure(target_path:, logger: OneshotCoverage::Logger::NullLogger.new, max_emit_at_once: nil)
    target_path_by_pathname =
      if target_path.is_a? Pathname
        target_path
      else
        Pathname.new(target_path)
      end
    @reporter = OneshotCoverage::Reporter.new(
      target_path: target_path_by_pathname.cleanpath.to_s + "/",
      logger: logger,
      max_emit_at_once: max_emit_at_once
    )
  end
end
