# coding: utf-8

require 'bundler'
Bundler.require

require 'singleton'
require 'yaml'
require 'json'

class SeminarCalender
  include Singleton

  AUTH = YAML.load_file("./google.yaml")
  CONFIG = YAML.load_file("./config.yaml")

  def initialize
    authorize
    get_events
  end

  def insert_event(event)
    result = @client.exec(:api_method => cal.events.insert,
                 :parameters => {'calendarId' => CONFIG[:cal_id]},
                 :body => JSON.dump(event),
                 :headers => {'Content-Type' => 'application/json'})
    result.status
  end

  privete
  
  def authorize 
    @client = Google::APIClient.new
    @client.authorization.client_id = AUTH[:client_id]
    @client.authorization.client_secret = AUTH[:client_secret]
    @client.authorization.scope = AUTH[:scope].first
    @client.authorization.refresh_token = AUTH[:refresh_token]
    @client.authorization.access_token = AUTH[:access_token]
    @client.authorization.redirect_uri = AUTH[:redirect_uri]
    @client.authorization.fetch_access_token!

    @cal = client.discovered_api('calendar', 'v3')
  end

  def get_events
    params = {'calendarId' => CONFIG[:cal_id], 
              'orderBy' => 'startTime',
              'timeMax' => Time.utc(CONFIG[:year].to_i + 1, 1, 4).iso8601, 
              'timeMin' => Time.utc(CONFIG[:year].to_i, 1, 4).iso8601,
              'singleEvents' => 'True'}
    
    results = @client.exec(:api_method => @cal.events.list, :parameters => params)
    results.status
  end
end
