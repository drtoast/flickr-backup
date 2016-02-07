#!/usr/bin/env ruby

require_relative 'lib/flickr'

options = JSON.parse(File.read(File.join(File.dirname(__FILE__), 'config.json')))
agent = Flickr::Agent.new(options)

case ARGV[0]
when 'token'
  agent.get_auth_token
when 'report'
  Flickr::Report.new(options).summary
when 'favorites'
  agent.fetch_favorites
else
  agent.fetch_photosets
end
