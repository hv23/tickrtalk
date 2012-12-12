# Be sure to restart your server when you modify this file

# Uncomment below to force Rails into production mode when
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|  
  config.frameworks -= [ :active_record ]
  
  config.gem 'mongo_mapper'
  config.gem "twitter"
  config.gem "fbgraph"
  config.gem "url_shortener"
  # config.gem 'will_paginate', :version => '~> 2.3.11', :source => 'http://gemcutter.org'  
  config.gem "paperclip"
  config.gem "contacts"
  config.gem "newrelic_rpm"
  config.gem "openfooty" #, :version => '0.2.0'
  config.gem "nokogiri"
  config.gem 'delayed_job'
  
  config.time_zone = 'Eastern Time (US & Canada)'

  config.action_controller.session = {
    :session_key => '_tickrtalk_session',
    :secret      => '99757e18669a187a5fb71ba258a440cb5268f3913e6b3f77d49c4d2a84d04f1cce040c860509dde4603edbb9c6f76aa339a89967b624ba14493cb95323816665'
  }
  
end

  FbConsumerConfig = YAML.load(File.read(Rails.root + 'config' + 'facebooker.yml'))
  ConsumerConfig = YAML.load(File.read(Rails.root + 'config' + 'consumer.yml'))
  SuperfeedrConfig = YAML.load(File.read(Rails.root + 'config' + 'superfeedr.yml'))
  
#  TWITTER_TOKEN = "EwXbWrCRINmbmQXAXsy96w"
#  TWITTER_SECRET = "bMEAPeC3XHhfPteyHqOqBQdVH6IQ0todohj93LA7lPQ"

# Disable FieldWithError
ActionView::Base.field_error_proc = proc { |input, instance| input }

# require "will_paginate"
# require "search"
