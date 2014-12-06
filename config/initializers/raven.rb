require 'raven'

raven_logger = ::Logger.new(STDOUT)
raven_logger.level = ::Logger::WARN

Raven.configure do |config|
  config.logger = raven_logger
end
