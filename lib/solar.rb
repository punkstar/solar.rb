# Add the lib directory to the load path so autoload can find our files
lib_path = File.expand_path("..", __FILE__)
$LOAD_PATH.unshift(lib_path) unless $LOAD_PATH.include?(lib_path)

require "debug"

module Solar
  autoload :Config, "solar/config"
  autoload :Provider, "solar/provider"
  autoload :Forecast, "solar/forecast"
  autoload :Repository, "solar/repository"
end