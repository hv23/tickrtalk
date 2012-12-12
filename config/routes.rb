ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.
  map.resources :users
  map.login 'login', :controller => 'user_sessions', :action => 'new'  
  map.logout 'logout', :controller => 'user_sessions', :action => 'destroy' 
  # map.connect 'users/send_status', :controller => "users", :action => "send_status" 
  
  map.mygamerooms 'mygamerooms', :controller => 'users', :action => 'gamerooms'
  
  map.admin_twitter_lists 'admin/twitter_lists', :controller => 'admin', :action => 'twitter_lists'
  map.admin 'admin', :controller => "admin", :action => "index"
  
  map.resources :user_sessions
  map.user_session 'user_session', :controller => "users", :action => "edit"
  
  map.account 'account', :controller => 'users', :action => 'edit' 
  map.signup 'signup', :controller => 'users', :action => 'new' 

	map.connect 'gameroom/:id', :controller => 'gameroom', :action => 'index'
	map.connect 'gameroom/:id/send_to_twitter', :controller => 'gameroom', :action => 'send_to_twitter'
	map.connect 'gameroom/:id/send_to_facebook', :controller => 'gameroom', :action => 'send_to_facebook'
	map.connect 'gameroom/:id/in_reply_to', :controller => 'gameroom', :action => 'in_reply_to'
	map.connect 'gameroom/:id/replies', :controller => 'gameroom', :action => 'replies'
	map.connect 'gameroom/:id/all_updates', :controller => 'gameroom', :action => 'all_updates'
	map.connect 'gameroom/:id/following', :controller => 'gameroom', :action => 'following'
	map.connect 'gameroom/:id/twitter_only', :controller => 'gameroom', :action => 'twitter_only'
	map.connect 'gameroom/:id/tickrtalk_only', :controller => 'gameroom', :action => 'tickrtalk_only'
	map.connect 'gameroom/:id/twitter_updates', :controller => 'gameroom', :action => 'twitter_updates'
	map.connect 'gameroom/:id/private_gameroom/:private_gameroom_id', :controller => 'gameroom', :action => 'private_gameroom'
	map.connect 'gameroom/:id/refresh_score', :controller => 'gameroom', :action => 'refresh_score'
	map.connect 'gameroom/:id/twitter_admin', :controller => 'gameroom', :action => 'twitter_admin'
	map.connect 'gameroom/:id/scores_admin', :controller => 'gameroom', :action => 'scores_admin'
	
	map.connect 'update/:id/in_reply_to', :controller => 'update', :action => 'in_reply_to'
		
	map.connect 'users/togglefollow', :controller => 'users', :action => 'togglefollow'
	map.connect 'users/:id', :controller => 'users', :action => 'show'
	map.connect 'teams', :controller => 'teams', :action => 'index'
	map.connect 'teams/quicksearch', :controller => 'teams', :action => 'quicksearch'
	map.connect 'teams/:id', :controller => 'teams', :action => 'view'
	map.connect 'update/:id', :controller => 'update', :action => 'view'
	map.connect 'league/:id', :controller => 'league', :action => 'view'
	
	map.teams_with_pages '/teams/league/:id/page/:page', :controller => 'teams', :action => 'league'
	
	map.resources :myteams
	map.connect 'myteams/autocomplete', :controller => 'myteams', :action => 'autocomplete'
	map.connect 'myteams/:id/removeteam', :controller => 'myteams', :action => 'removeteam'
	
	map.connect '/widgets/:action', :controller => 'widgets'
	
	map.connect 'games/add_big_game', :controller => "games", :action => "add_big_game"
	map.resources :games
	map.resources :private_updates
	map.connect 'private_gamerooms/:id/edit', :controller => "private_gamerooms", :action => "edit"
	map.connect 'private_gamerooms/add_contacts', :controller => "private_gamerooms", :action => "add_contacts"
	map.connect 'private_gamerooms/fill_contacts', :controller => "private_gamerooms", :action => "fill_contacts"
	map.connect 'private_gamerooms/find_contacts', :controller => "private_gamerooms", :action => "find_contacts"
	map.resources :private_gamerooms
	map.resources :private_gameroom_sessions

  map.resource :session
  map.finalize_session 'sessions/finalize', :controller => 'sessions', :action => 'finalize'
  map.logout_twitter 'logout_twitter', :controller => 'sessions', :action => 'logout_twitter'
  map.twitter_signup 'twitter_signup', :controller => 'sessions', :action => 'twitter_signup'
  map.facebook_session 'sessions/facebook_create', :controller => 'sessions', :action => 'facebook_create'
  map.facebook_finalize_session 'sessions/facebook_finalize', :controller => 'sessions', :action => 'facebook_finalize'
  map.facebook_signup 'facebook_signup', :controller => 'sessions', :action => 'facebook_signup'
  map.logout_facebook 'logout_facebook', :controller => 'sessions', :action => 'logout_facebook'
  
  map.connect 'about', :controller => "home", :action => "about"
  map.connect 'terms', :controller => "home", :action => "terms"
  map.connect 'privacy', :controller => "home", :action => "privacy"
  
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.connect ':controller/:action.:format'
end
