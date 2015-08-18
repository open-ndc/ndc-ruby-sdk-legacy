require "nokogiri"
require "savon"

require_relative "core_ext/object"
extends_path = "#{File.dirname(__FILE__)}/core_ext/*.rb"
Dir[extends_path].each {|file|
  require file
}

require_relative "version"
require_relative "ndc-client/errors"
require_relative "ndc-client/base"
require_relative "ndc-client/config"

messages_path = "#{File.dirname(__FILE__)}/ndc-client/messages/*.rb"
Dir[messages_path].each {|file|
  require file
}

# Dev
require "pry"
