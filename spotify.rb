#!/usr/bin/env ruby
 
require 'rubygems'
require 'httparty'
require 'rest_client'
require 'json'
require 'pp'
 
class Spotify
  include HTTParty
  
  base_uri 'localhost:3333'
  
  def self.artists(name)
    get("/artists", :query => {:name => name})
  end
  def self.tracks(name, artist=nil)
    results = get("/tracks", :query => {:name => name, :artist => artist})
    raise results.inspect if results["status"] != "OK"
    results["result"].first
  end
  def self.albums(name)
    results = get("/albums", :query => {:name => name, :artist => artist})
    raise results.inspect if results["status"] != "OK"
    results["result"]
  end
  def self.playlists(name=nil)
    results = get("/playlists")
    raise results.inspect if results["status"] != "OK"
    if name.nil?
      results["result"]
    else
      # puts results.inspect
      p = results["result"]["playlists"].select{|e| e["name"].downcase == name.downcase}
      return nil if p.empty?
      return p
    end
  end

  def self.update_playlist(id, tracks=nil, name=nil)
    puts "replacing tracks in #{id}"
    data = {}
    data["tracks"] = tracks unless tracks.nil?
    data["name"] = name unless name.nil?
    resp = put("/playlists/#{id}", :body => data.to_json)
    puts resp.inspect
  end
  
  def self.create_playlist(name)
    puts "creating a new playlist"
    # this post throws error with httparty - must investigate
    resp = RestClient.post("http://#{base_uri}/playlists", :name => name)
    if resp.code == 201
      location = resp.headers[:location]
      puts "201 created (#{location})"
      spotify_id = location[location.rindex('/')+1..-1]
      return spotify_id
    else
      raise resp.to_s
    end
  end
  
end