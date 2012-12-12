class Notifier < ActionMailer::Base
  default_url_options[:host] = "tickrtalk.com"
  
  def gameroom_invitations(user, invitees, gameroom)
    subject       "TickrTalk - You've been invited to join a private gameroom!"  
    recipients    invitees 
    from          "johnny@tickrtalk.com"
    sent_on       Time.current  
    body          :user => user.email, :private_gameroom_url => PrivateGameroom.bitly("#{root_url}gameroom/#{gameroom.game_id}/private_gameroom/#{gameroom.id}?gameroom_key=#{gameroom.gameroom_key}"), :game => Game.find(gameroom.game_id).name
    reply_to      "'TickrTalk' <private-gameroom-invitation@tickrtalk.com>"
  end

end
