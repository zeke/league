# { name: "Tom Coleman", email: "tom@thesnail.org", facebook_id: 'xxx', team_ids: [..], 
#   authorized: true, messaged: true}

class Player extends Model
  constructor: (attrs) ->
    super(attrs)
    @attributes.team_ids ||= []
    
  valid: ->
    @errors = {}
    
    # Obviously we'd prefer rails style class-level validators
    # unless @attributes.name? and @attributes.name != ''
    #   @errors.name = 'must not be empty'
      
    # unless @attributes.facebook_id? and parseInt(@attributes.facebook_id) > 0
    #   @errors.facebook_id = 'must be a positive number'
    
    _.isEmpty(@errors)
  
  @find_by_userId: (userId) ->
    Players.findOne(Meteor.users.findOne(userId).player_id)
  
  @new_from_user: (user, extra) ->
    data = { name: extra.name, email: user.emails[0] }
    data.facebook_id = user.services.facebook.id if user.services.facebook
    
    new this(data)
  
  profile_url: (type = 'normal') ->
    if (@attributes.facebook_id)
      facebook_profile_url(type)
    else
      # Note this only works client side right now
      hash = CryptoJS.MD5(@attributes.email.trim().toLowerCase())
      "http://www.gravatar.com/avatar/#{hash}"
    
  facebook_profile_url: (type = 'normal') ->
    "https://graph.facebook.com/#{@attributes.facebook_id}/picture?type=#{type}"
    
  create_team: (attributes) ->
    team = new Team(attributes)
    team.add_player(this)
  
  send_facebook_message: (message, link, callback) ->
    data =
      method: 'send'
      to: @attributes.facebook_id
      message: message
      link: link
    FB.ui data, (result) =>
      # this is the only way we can tell if they've actually sent it, thanks FB
      if result?
        this.update_attribute('messaged', true)
        callback() if callback

Player.has_access = (userId, raw_player, fields) ->
  console.log('checking access for player')
  console.log(fields);
  console.log(raw_player);
  return true unless raw_player._id
  
  # obviously, you can edit yourself
  me = Player.find_by_userId(userId)
  return true if me.id == raw_player._id
  
  # otherwise check that the player is in a team with the user
  team_ids = Players.find(raw_player._id).attributes.team_ids
  our_team_ids = me.attributes.team_ids
  
  console.log(team_ids)
  console.log(our_team_ids)
  console.log(_.intersection(team_ids, our_team_ids));
  
  _.intersection(team_ids, our_team_ids) != []
  
Players = Player._collection = new Meteor.Collection 'players', null, null, null, Player

## add security
Players.allow
  insert: Player.has_access
  update: Player.has_access
  remove: Player.has_access
