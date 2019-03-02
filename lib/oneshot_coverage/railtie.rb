unless defined? Rails::Railtie
  raise "You need to install and require Rails to use this integration"
end

module OneshotCoverage
  class Railtie < Rails::Railtie
    initializer 'oneshot_coverage.configure' do |app|
      app.middleware.use OneshotCoverage::Middleware
    end
  end
end
