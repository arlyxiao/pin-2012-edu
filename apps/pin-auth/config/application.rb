require File.expand_path('../boot', __FILE__)

require 'rails/all'

if defined?(Bundler)
  Bundler.require(*Rails.groups(:assets => %w(development test)))
end

module MindpinEduSns
  class Application < Rails::Application
    # load mindpin lib
    require "#{Rails.root}/../../lib/mindpin_rails_loader"
    MindpinRailsLoader.new(config).load
    
    config.assets.paths << Rails.root.join('..', 'pin-edu-sns', 'app', 'assets', 'stylesheets')
    config.assets.paths << Rails.root.join('..', 'pin-edu-sns', 'app', 'assets', 'javascripts')
  end
end
