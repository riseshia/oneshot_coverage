module OneshotCoverage
  module Logger
    class NullLogger
      def post(_row)
        # Do nothing
        true
      end
    end
  end
end
