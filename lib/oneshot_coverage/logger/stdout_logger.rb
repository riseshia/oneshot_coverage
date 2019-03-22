module OneshotCoverage
  module Logger
    class StdoutLogger
      def post(path:, md5_hash:, lineno:)
        $stdout.puts(
          "[OneshotCoverage] logged path: #{path}, md5_hash: #{md5_hash}, lineno: #{lineno}"
        )
        true
      end
    end
  end
end
