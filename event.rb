# coding: utf-8

require 'bundler'
Bundler.require

require 'open-uri'
require 'yaml'
require 'json'

class Event
  CONFIG = YAML.load_file("./config.yaml")

  # some class methods
  class << self
    # get evets list from web site
    # return the ary of Event
    def get_events
      events_ary = []

      doc = Nokogiri::HTML(open(CONFIG[:target_url]))
      doc.css("div > table > tbody > tr").each do |tr|
        ary_tmp = []
        tr.children.each do |td|
          ary_tmp << td.content.encode('utf-8')
        end
        hash_table = ary_to_hash(ary_tmp)
        next unless hash_table # when date is not determined
        begin
          events_ary << Event.new(hash_table)
        rescue NoScheduleError
          next
        end
      end
      events_ary
    end

    # load from JSON string to Event obj.
    # cf. Event#dump
    def load(str)
      hash = JSON.parse(str, {:symbolize_names => true})
      p hash
      puts hash.class
      begin
        Event.new(hash)
      rescue NoScheduleError
        nil
      end
    end

    private

    def ary_to_hash(ary)
      # when the date is not determined, return nil
      return nil unless ary.first

      hash = {}; hash[:date] = {}; hash[:time] = {}
      hash[:date][:month], hash[:date][:day] = get_date(ary[0])
      hash[:time][:hour], hash[:time][:min] = get_time(ary[1])
      hash[:place] = ary[2]
      hash[:people] = ary[3]

      hash 
    end

    def get_date(str)
      str =~ /(\d+)月(\d+)日/
      return $1, $2
    end

    def get_time(str)
      str =~ /(\d+):(\d+)/
      return $1, $2
    end
  end

  # initialize with;
  # hash[:date > :month/:day],[:time > :hour/:min],[:people],[:place]
  def initialize(hash)
    @hash = hash
    @date = hash[:date]
    @time = hash[:time]
    @people = hash[:people]
    @place = hash[:place]

    # not create object if date/time is not set
    raise NoScheduleError unless (@date[:day] && @date[:month] && @time[:hour] && @time[:min])
  end

  # output method for google calendar event insertion
  def output
    case @date[:month].to_i
    when 4..12 then year = CONFIG[:year].to_i
    when 1..3 then year = CONFIG[:year].to_i + 1
    end
    {
      'summary' => "#{@people}@#{@place}",
      'start' => {
        'dateTime' => Time.utc(0, @time[:min], @time[:hour].to_i - 9 , @date[:day], @date[:month], year, nil, nil, false, nil).iso8601
      },
      'end' => {
        'dateTime' => Time.utc(0, @time[:min], @time[:hour].to_i - 9 + CONFIG[:duration], @date[:day], @date[:month], year, nil, nil, false, nil).iso8601
      },
      'location' => @place
    }  	
  end

  def to_s
    @hash.to_s
  end

  # for saving the object to JSON txt format
  def dump
    JSON.dump(@hash)
  end

  def ==(other)
    raise ArgumentError unless other.class.to_s == "Event"
    self.dump == other.dump
  end
end

class NoScheduleError < StandardError; end

if __FILE__ == $0
  ary = Event.get_events
  puts ary

  puts "Dumping..."
  puts dump = ary.first.dump

  puts "Loading..."
  event = Event.load(dump)
  puts event

  puts event == ary.first
  puts event == ary.last
end
