#!/usr/bin/ruby

require 'rubygems'
require 'hpricot'
require 'lastfm'
require 'spotify'

username = ARGV.first

tracks = []
Lastfm.top_tracks_7day_tracks(username).each do |track|
  track = Spotify.tracks(track["title"], track["artist"])
  tracks << track unless track.nil?
end

# Spotify.create_playlist(username, tracks)
# playlist = Spotify.playlists(name) || Spotify.create_playlist(name)

p = Spotify.playlists(username)
if p 
  p_id = p.first["id"]
else
  p_id = Spotify.create_playlist(username)
end
Spotify.update_playlist(p_id, tracks)