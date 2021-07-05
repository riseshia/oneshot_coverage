require "test_helper"

require "json"

class OneshotCoverageTest < Minitest::Test
  def setup
    @coverage_file_path = "target_app/coverage.json"
    if File.exist?(@coverage_file_path)
      File.delete(@coverage_file_path)
    end
  end

  def actual_logs
    assert File.exist?(@coverage_file_path)
    JSON.load(File.read(@coverage_file_path))
  end

  def test_default_behavior
    Dir.chdir("target_app") do
      system("bundle exec ruby cover_code_test.rb")
    end
    expected = {
      "adder.rb-e4e5063f874fdd16febba4e8b8b2448b" => [1,2,7,3,4,8]
    }
    assert_equal expected, actual_logs
  end

  # check only recorded or not
  def test_with_cover_bundle_path
    Dir.chdir("target_app") do
      system("COVER_BUNDLE_PATH=1 bundle exec ruby cover_code_test.rb")
    end

    logs = actual_logs
    assert_equal logs["adder.rb-e4e5063f874fdd16febba4e8b8b2448b"], [1,2,7,3,4,8]

    logs_from_bundled_gem = logs.select { |log| log.include?("minitest-") }
    assert_equal logs_from_bundled_gem.size, 5
  end
end
