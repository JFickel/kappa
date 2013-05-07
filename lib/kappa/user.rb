module Kappa
  class UserBase
    include IdEquality

    def initialize(hash, connection = self.class.default_connection)
      @connection = connection
      parse(hash)
    end

    #
    # GET /users/:user
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/users.md#get-usersuser
    #
    def self.get(user_name, connection = default_connection)
      json = connection.get("users/#{user_name}")
      if json['status'] == 404
        nil
      else
        new(json, connection)
      end
    end

  private
    def self.default_connection
      self.class.module_class(:Connection).instance
    end
  end
end

module Kappa::V2
  class User < Kappa::UserBase
    def channel
      # TODO
    end

    def staff?
      @staff
    end

    #
    # GET /channels/:channel/subscriptions/:user
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/subscriptions.md#get-channelschannelsubscriptionsuser
    #
    # TODO: Requires authentication.
    def subscribed_to?(channel_name)
    end

    #
    # GET /streams/followed
    # TODO: Authenticate.
    # TODO: Only valid for authenticated user, might not belong here.
    #
    # GET /users/:user/follows/channels
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/follows.md#get-usersuserfollowschannels
    #
    def following(params = {})
      limit = params[:limit] || 0

      channels = []
      ids = Set.new

      @connection.paginated("users/#{@name}/follows/channels", params) do |json|
        current_channels = json['follows']
        current_channels.each do |follow_json|
          channel_json = follow_json['channel']
          channel = Channel.new(channel_json, @connection)
          if ids.add?(channel.id)
            channels << channel
            if channels.count == limit
              return channels
            end
          end
        end

        !current_channels.empty?
      end

      channels
    end

    #
    # GET /users/:user/follows/:channels/:target
    # https://github.com/justintv/Twitch-API/blob/master/v2_resources/follows.md#get-usersuserfollowschannelstarget
    #
    def following?(channel_name)
      json = @connection.get("users/#{@name}/follows/channels/#{channel_name}")
      status = json['status']
      return !status || (status != 404)
    end

    attr_reader :id
    attr_reader :created_at
    attr_reader :display_name
    attr_reader :logo_url
    attr_reader :name
    attr_reader :updated_at

    # TODO: Authenticated user attributes.
    # attr_reader :email
    # def partnered?
    
  private
    def parse(hash)
      @id = hash['_id']
      @created_at = DateTime.parse(hash['created_at'])
      @display_name = hash['display_name']
      @logo_url = hash['logo']
      @name = hash['name']
      @staff = hash['staff'] || false
      @updated_at = DateTime.parse(hash['updated_at'])
    end
  end
end