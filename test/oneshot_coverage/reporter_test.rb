require "test_helper"

module OneshotCoverage
  class ReporterTest < Minitest::Test
    class MemoryLogger
      def initialize
        @logs = {}
      end

      def post(logs)
        logs.each do |log|
          key = "#{log.path}-#{log.md5_hash}"
          @logs[key] = log.lines
        end
      end

      def logs
        @logs
      end
    end

    module DummyCoverage
      module_function

      def result(clear:, stop:)
        logged
      end

      def clear
        logged.clear
      end

      def add(file, lines)
        logged[file] = { oneshot_lines: lines }
      end

      def logged
        @logged ||= {}
      end
    end

    def teardown
      DummyCoverage.clear
    end

    def build_reporter
    end

    def test_reporter
      logger = MemoryLogger.new
      reporter = Reporter.new(
        coverage_module: DummyCoverage,
        target_path: "target_app/",
        logger: logger,
        emit_term: nil,
        cover_bundle_path: false
      )
      DummyCoverage.add("target_app/multiplexer.rb", [])
      DummyCoverage.add("target_app/adder.rb", [1, 2, 3, 5, 7, 9, 11])
      DummyCoverage.add("non_target_app/adder.rb", [2, 4, 6, 8])
      reporter.emit(true)

      expected_logs = {
        "adder.rb-e4e5063f874fdd16febba4e8b8b2448b" => [1, 2, 3, 5, 7, 9, 11]
      }
      assert_equal expected_logs, logger.logs
    end

    def test_reporter_with_bundler
      logger = MemoryLogger.new
      reporter = Reporter.new(
        coverage_module: DummyCoverage,
        target_path: "target_app/",
        logger: logger,
        emit_term: nil,
        cover_bundle_path: true
      )

      DummyCoverage.add("target_app/adder.rb", [1, 2, 3, 5, 7, 9, 11])
      file_under_bundler = "#{Bundler.bundle_path}/adder.rb"
      md5_cache = reporter.send(:md5_hash_cache)
      # Avoid to read file...
      md5_cache[file_under_bundler] = "mmmddd555"
      DummyCoverage.add(file_under_bundler, [2, 4, 6, 8])

      reporter.emit(true)

      expected_logs = {
        "adder.rb-e4e5063f874fdd16febba4e8b8b2448b" => [1, 2, 3, 5, 7, 9, 11],
        "#{file_under_bundler}-mmmddd555" => [2, 4, 6, 8]
      }
      assert_equal expected_logs, logger.logs
    end
  end
end
