# coding: utf-8

require 'bundler'
Bundler.require
require 'open-uri'

class Event
  CONFIG = YAML.load_file("./config.yaml")

  # get evets list from web site
  # return the ary of Event
  def self.get_events
    doc = Nokogiri::HTML(open(CONFIG[:target_url]))
    doc.css("div > table > tbody > tr").each do |tr|
      ary_tmp = []
      tr.children.each do |td|
        ary_tmp << td.content.encode('utf-8')
      end

    end
  end

  # initialize with;
  # hash[:date > :month/:day],[:time > :hour/:min],[:people],[:place]
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
        'dateTime' => Time.utc(0, @time[:min], @time[:hour] - 9 + CONFIG[:duration], @date[:day], @date[:month], CONFIG[:year], nil, nil, false, nil).iso8601
      },
      'location' => @place
    }  	
  end
  
end
