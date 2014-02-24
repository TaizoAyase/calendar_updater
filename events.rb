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
    @time = hash[:time]
    @people = hash[:people]
    @place = hash[:place]
  end

  def output
    {
      'summary' => "#{@people}@#{@place}",
      'start' => {
        'dateTime' => Time.utc(0, @time[:min], @time[:hour] - 9 , @date[:day], @date[:month], CONFIG[:year], nil, nil, false, nil).iso8601
      },
      'end' => {
        'dateTime' => Time.utc(0, @time[:min], @time[:hour] - 9 + 2, @date[:day], @date[:month], CONFIG[:year], nil, nil, false, nil).iso8601
      },
      'location' => @place
    }  	
  end
  
end
