$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

require 'simplecov'
require 'oneshot_coverage/simplecov_reporter'

OneshotCoverage::SimplecovReporter.new(
  project_path: Dir.pwd,
  log_path: 'coverage.json',
  file_filter: OneshotCoverage::SimplecovReporter::DefaultFilter
).run
