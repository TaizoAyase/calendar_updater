# coding: utf-8

require 'bundler'
Bundler.require

key_file = Dir.glob("client_secret_*.apps.googleusercontent.com.json")
raise unless key_file.length == 1
system("cp #{key_file.first} ./client_secrets.json")

client_secrets = Google::APIClient::ClientSecrets.load

client = Google::APIClient.new
client.authorization.client_id = client_secrets.client_id
client.authorization.client_id = client_secrets.client_secret
client.authorization.scope = "https://www.googleapis.com/auth/calendar"
client.authorization.redirect_uri = client_secrets.redirect_uris.first

uri = client.authorization.authorization_uri
Launchy.open(uri)

# Exchange authorization code for access token
$stdout.write  "Enter authorization code: "
client.authorization.code = gets.chomp
client.authorization.fetch_access_token!
