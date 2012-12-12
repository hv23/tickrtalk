class LeagueController < ApplicationController
	layout 'welcome'
  before_filter :tickrtalk_credentials
  before_filter :clear_contacts
	
	def view
		
	end
end
