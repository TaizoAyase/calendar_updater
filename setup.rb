# coding: utf-8

require 'google/api_client'
require 'Launchy'
require 'yaml'

key_file = Dir.glob("client_secret_*.apps.googleusercontent.com.json")
raise unless key_file.length == 1
system("cp #{key_file.first} ./client_secrets.json")

client_secrets = Google::APIClient::ClientSecrets.load

client = Google::APIClient.new
client.authorization.client_id = client_secrets.client_id
client.authorization.client_secret = client_secrets.client_secret
client.authorization.scope = "https://www.googleapis.com/auth/calendar"
client.authorization.redirect_uri = client_secrets.redirect_uris.first

uri = client.authorization.authorization_uri
Launchy.open(uri)

# Exchange authorization code for access token
$stdout.write  "Enter authorization code: "
client.authorization.code = gets.chomp
client.authorization.fetch_access_token!

# dump configs to yaml file
hash = Hash.new
hash[:client_id] = client.authorization.client_id
hash[:client_secret] = client.authorization.client_secret
hash[:scope] = client.authorization.scope
hash[:redirect_uri] = client.authorization.redirect_uri
hash[:refresh_token] = client.authorization.refresh_token
hash[:access_token] = client.authorization.access_token

str = YAML.dump(hash)
File.write("google.yaml", str)


