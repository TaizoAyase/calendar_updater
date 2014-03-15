# coding: utf-8

require './event'
require 'google/api_client'
require 'singleton'
require 'yaml'
require 'json'

class SeminarCalender
  include Singleton

  AUTH = YAML.load_file("./google.yaml")
  CONFIG = YAML.load_file("./config.yaml")
  APP_NAME = "CalendarUpdater"
  VERSION = "beta"

  def initialize
    authorize # set @client
    fetch_events # set @events_list
  end

  def events_list
    fetch_events
    @events_list
  end

  def insert_event(event)
    result = @client.execute(:api_method => cal.events.insert,
                 :parameters => {'calendarId' => CONFIG[:cal_id]},
                 :body => JSON.dump(event),
                 :headers => {'Content-Type' => 'application/json'})
    result.status
  end

  private
  
  def authorize 
    @client = Google::APIClient.new({:application_name => APP_NAME, :application_version => VERSION})
    @client.authorization.client_id = AUTH[:client_id]
    @client.authorization.client_secret = AUTH[:client_secret]
    @client.authorization.scope = AUTH[:scope].first
    @client.authorization.refresh_token = AUTH[:refresh_token]
    @client.authorization.access_token = AUTH[:access_token]
    @client.authorization.redirect_uri = AUTH[:redirect_uri]
    @client.authorization.fetch_access_token!

    @cal = @client.discovered_api('calendar', 'v3')
  end

  # access cal to get events list
  def fetch_events
    params = {'calendarId' => CONFIG[:cal_id], 
              'orderBy' => 'startTime',
              'timeMax' => Time.utc(CONFIG[:year].to_i + 1, 4, 1).iso8601, 
              'timeMin' => Time.utc(CONFIG[:year].to_i, 4, 1).iso8601,
              'singleEvents' => 'True'}
    
    result = @client.execute(:api_method => @cal.events.list, :parameters => params)

    @events_list = []
    result.data.items.each do |item|
      @events_list << item
    end
  end
end

if __FILE__ == $0
  cal = SeminarCalender.instance
  puts cal.events_list.class
  puts cal.events_list.first.class
  puts cal.events_list.first.id
end
