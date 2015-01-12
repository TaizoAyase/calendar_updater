# coding: utf-8

require 'bundler'
Bundler.require

require 'yaml'
require './event'
require './calendar'

CONFIG = YAML.load_file("./config.yaml")
last_mod_time = Marshal.load(File.read("./tmp/timestamp.tmp"))
mod_time = File.mtime(CONFIG[:target_path])
if mod_time <= last_mod_time
  puts "List is not modified."
  exit(status = true)
end

# 150112FIX
# mod_time was not written to tmp file
File.write("./tmp/timestamp.tmp", 'w') do |f|
  f.puts Marshal.dump(mod_time)
end

puts Time.now

# fetch the events from web
events_onWeb = Event.get_events

# load the old event list from JSON file 
begin
  f = File.open('./tmp/event_old.json')
  events_local = []
  while line = f.gets
    events_local << Event.load(line)
  end
  f.close
rescue => e
  puts e
  puts e.message
  events_local = []
end

=begin
140321:TODO defference array cannot be generated
this might be a bug of ruby???
# get the difference
#diff1 = (events_onWeb - events_local)
#diff2 = events_local - events_onWeb
#diff = diff1 | diff2

unless diff.empty?
  cal = SeminarCalendar.instance

  # delete all events on google cal
  cal.events_list.each do |event|
    cal.delete_event(event.id)
  end

  # make event on google 
  events_onWeb.each do |event|
    cal.insert_event(event.output)
  end
end
=end

cal = SeminarCalendar.instance

# delete all events on google cal
puts "Deleting events..."
cal.events_list.each do |event|
  result = cal.delete_event(event.id)
  puts "#{result.status} for #{event.summary}".encode('utf-8')
end

# make event on google 
puts "Making events..."
events_onWeb.each do |event|
  result = cal.insert_event(event.output)
  puts "#{result.status} for #{event.people}".encode('utf-8')
end

# dump to tmp file as old file
ary = []
events_onWeb.each do |event|
  ary << event.dump + "\n"
end

File.open('./tmp/event_old.json', 'w+') do |out_file|
  out_file.puts ary.to_s.encode('utf-8')
end
