$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "oneshot_coverage"
require "oneshot_coverage/logger/file_logger"

OneshotCoverage.configure(
  target_path: Dir.pwd,
  logger: OneshotCoverage::Logger::FileLogger.new('coverage.json'),
  emit_term: nil,
  cover_bundle_path: ENV["COVER_BUNDLE_PATH"] == "1",
)

OneshotCoverage.start

require "minitest"
require_relative "adder"

Adder.new(1, 2).call
