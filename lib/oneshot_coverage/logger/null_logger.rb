module OneshotCoverage
  module Logger
    class NullLogger
      def post(_row)
        # Do nothing
      end
    end
  end
end
