#!/usr/bin/env ruby
 
require 'rubygems'
require 'httparty'
 
class Lastfm
  include HTTParty
 
  # http_proxy '127.0.0.1', 8123
  base_uri 'ws.audioscrobbler.com'
  default_params :api_key => 'd64ba82baaf21554416b25365c114455'
 
  GENERIC_TAGS = [ /female vocalists?/i, /seen live/i, /awesome/i, /beautiful/i, /\Aparty\Z/i, /dreamy/i, /\Ahappy\Z/i ]
 
  class <<self
    def ensure_user_exists(user_id)
      raise ArgumentError, "need user_id" if user_id.nil?
      query('user.getRecentTracks', :user=>user_id, :limit=>1)
    end
 
    def loved_tracks(user_id)
      query('user.getLovedTracks', :user=>user_id, :limit=>10)['lovedtracks']['track'].map do |r|
          { 'artist' => r['artist']['name'], 'title'=>r['name'], 'mbid' => r['mbid'] }
      end
    end
 
    def recent_tracks(user_id)
      query('user.getRecentTracks', :user=>user_id, :limit=>100)['recenttracks']['track'].map do |r|
          { 'artist' => r['artist'], 'title'=>r['name'], 'mbid' => r['mbid'] }
      end
    end
 
     def top_tracks(user_id, period='overall')
      query('user.getTopTracks', :period=>period, :user=>user_id)['toptracks']['track'].map do |r|
          { 'artist' => r['artist']['name'], 'title'=>r['name'], 'mbid' => r['mbid'] }
      end
    end
 
    ['overall', '7day', '3month', '6month', '12month'].each do |period|
      (class << Lastfm; self; end).send(:define_method, "top_tracks_#{period}_tracks".to_sym) { |id| top_tracks(id, period) }
    end
 
    def query(method, args={})
     result = get("/2.0/", :query => { :method => method }.merge(args))
     raise result['lfm']['error'] if result['lfm'] && result['lfm']['status'] == 'failed'
     result['lfm']
    end
 
 
    def tags(songs,opts={})
      threshold = opts[:threshold].to_i > 0 ? opts[:threshold].to_i : -1
      tags = songs.inject([]) do |list, song|
        result = query("track.gettoptags", :artist=>song['artist'], :track=>song['title'], :mbid=>song['mbid'])
        if result && result['toptags'] && result['toptags']['tag']
          list << [result['toptags']['tag']].flatten.sort { |a,b| b['count'].to_i <=> a['count'].to_i }[0..threshold]
        end
        list
      end.flatten
 
      tags.reject! {|t| GENERIC_TAGS.any? {|gt| gt.match(t['name']) } }
      tags
    end
 
  end
end