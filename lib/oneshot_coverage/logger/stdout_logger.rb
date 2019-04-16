module OneshotCoverage
  module Logger
    class StdoutLogger
      def post(logs)
        logs.each do |log|
          $stdout.puts(
            "[OneshotCoverage] logged path: #{log.path}, md5_hash: #{log.md5_hash}, executed_lines: #{log.lines}"
          )
        end
      end
    end
  end
end
