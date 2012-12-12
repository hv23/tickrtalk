class WidgetsController < ApplicationController
  layout nil
	
  def stream
    @recent_updates = Update.all(:order => "date_created desc", :limit => 30)
    @contents = render_to_string(:partial => 'recent_updates' )
    @style = " some css here"
    
    respond_to do |format|
      format.html
      format.js
    end
  end
  
  def test
    
  end
end
