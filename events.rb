# coding: utf-8

require 'bundler'
Bundler.require
require 'open-uri'

class Events
  CONFIG = YAML.load_file("./config.yaml")
  
  def self.get_events

  end

  def initialize(hash)
    @date = hash[:date]
    @people = hash[:people]
    @place = hash[:place]
  end

  
end
