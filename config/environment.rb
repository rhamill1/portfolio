# Load the Rails application.
require_relative 'application'
require 'neo4j/railtie'

# Initialize the Rails application.
Rails.application.initialize!

config.action_dispatch.default_headers.clear
