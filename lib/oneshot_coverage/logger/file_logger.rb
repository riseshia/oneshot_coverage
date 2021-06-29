require 'json'

module OneshotCoverage
  module Logger
    class FileLogger
      def initialize(log_path)
        @log_path = log_path
      end

      def post(new_logs)
        current_coverage = fetch

        new_logs.each do |new_log|
          key = "#{new_log.path}-#{new_log.md5_hash}"

          logged_lines = current_coverage.fetch(key, [])
          current_coverage[key] = logged_lines | new_log.lines
        end
        save(current_coverage)
      end

      private

      def fetch
        JSON.load(File.read(@log_path)) || {}
      rescue Errno::ENOENT
        {}
      end

      def save(data)
        File.write(@log_path, JSON.dump(data))
      end
    end
  end
end
