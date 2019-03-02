# OneshotCoverage

This gem is not very useful when you want to use oneshot coverage,
however, It could be good example to implement it by yourself.

This gem is to provide simple tools to use OneshotCoverage easier. It will log
files under the target path(usually, project base path).
In other word, This gem do not log codes under bundler gem path(if exist).

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'oneshot_coverage'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install oneshot_coverage

## Usage

### Configuration

```ruby
OneshotCoverage.configure(
  target_path: '/base/project/path',
  logger: OneshotCoverage::Logger::NullLogger.new,
)
OneshotCoverage.start
```

As default, OneshotCoverage supports 2 logger.

- OneshotCoverage::Logger::NullLogger (default)
- OneshotCoverage::Logger::StdoutLogger

Only required interface is `#post` instance method, so you could implement
by yourself easily.

```ruby
class SampleFluentLogger
  def initialize
    @logger = Fluent::Logger::FluentLogger.new('tag_prefix')
  end

  def post(path:, md5_hash:, lineno:)
    @logger.post(nil, path: path, md5_hash: md5_hash, lineno: lineno)
  end
end
```

### Emit logs

#### With rack application

Please use `OneshotCoverage::Middleware`. This will emit logs per each request.

If you using Rails, below is enough.

```
require 'oneshot_coverage/railtie'
```

### With job or batch application

If your job or batch are exit as soon as it finished(i.e. execute via rails runner),
then you don't need to do anything. `OneshotCoverage.start` will set trap
to emit via `at_exit`.
On the other hand, it's not, then you need to emit it manually
at proper timing(i.e. when batch finished)

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the OneshotCoverage project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/riseshia/oneshot_coverage/blob/master/CODE_OF_CONDUCT.md).
