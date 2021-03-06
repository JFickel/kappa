require 'cgi'
require 'time'

module Kappa::V2
  # @private
  class ChannelProxy
    def initialize(name, display_name)
      @name = name
      @display_name = display_name
    end

    attr_reader :name
    attr_reader :display_name

    include Proxy

    proxy {
      Channel.get(@name)
    }
  end

  # Videos are broadcasts or highlights owned by a channel. Broadcasts are unedited
  # videos that are saved after a streaming session. Highlights are videos edited from
  # broadcasts by the channel's owner.
  # @see .get Video.get
  # @see Videos
  # @see Channel
  class Video
    include Connection
    include Kappa::IdEquality

    # @private
    def initialize(hash)
      @id = hash['_id']
      @title = hash['title']
      @recorded_at = Time.parse(hash['recorded_at']).utc
      @url = hash['url']
      @view_count = hash['views']
      @description = hash['description']
      @length = hash['length']
      @game_name = hash['game']
      @preview_url = hash['preview']

      @channel = ChannelProxy.new(
        hash['channel']['name'],
        hash['channel']['display_name']
      )
    end

    # Get a video by ID.
    # @example
    #   v = Video.get('a396294648')
    #   v.title # => "DreamHack Open Stockholm 26-27 April"
    # @param id [String] The ID of the video to get.
    # @raise [ArgumentError] If `id` is `nil` or blank.
    # @return [Video] A valid `Video` object if the video exists, `nil` otherwise.
    def self.get(id)
      raise ArgumentError if !id || id.strip.empty?

      encoded_id = CGI.escape(id)
      json = connection.get("videos/#{encoded_id}")
      if !json || json['status'] == 404
        nil
      else
        new(json)
      end
    end

    # @note This is a `String`, not a `Fixnum` like most other object IDs.
    # @example
    #   v = Video.get('a396294648')
    #   v.id # => "a396294648"
    # @return [String] Unique Twitch ID for this video.
    attr_reader :id

    # @return [String] Title of this video. This is seen on the video's page.
    attr_reader :title

    # @return [Time] When this video was recorded (UTC).
    attr_reader :recorded_at

    # @return [String] URL of this video on Twitch.
    attr_reader :url

    # @return [Fixnum] The number of views this video has received all-time.
    attr_reader :view_count

    # @return [String] Description of this video.
    attr_reader :description

    # @example
    #   v.length # => 4205 (1 hour, 10 minutes, 5 seconds)
    # @return [Fixnum] The length of this video (seconds).
    attr_reader :length

    # @return [String] The name of the game played in this video.
    attr_reader :game_name

    # @return [String] URL of a preview screenshot taken from the video stream.
    attr_reader :preview_url

    # @return [Channel] The channel on which this video was originally streamed.
    attr_reader :channel
  end

  # Query class used for finding top videos.
  # @see Video
  class Videos
  end
end
