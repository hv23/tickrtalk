class TwitterList
  include MongoMapper::Document
  
  key :sport, String
  key :user, String
  
  def self.wefollow(link, sport)
    require 'open-uri'
    
    doc = Nokogiri::HTML(open(link))
    
    lists = TwitterList.all(:sport => sport).collect(&:user)

    doc.css('p.result_header').each do |wefollow_user| 
      unless lists.include?(wefollow_user.content)     
        TwitterList.create(:sport => sport, :user => wefollow_user.content)
      end
    end
	end
	
  def self.listorious(link, sport)
    require 'open-uri'
    
    doc = Nokogiri::HTML(open(link))
    
    lists = TwitterList.all(:sport => sport).collect(&:user)

    doc.css('h4 > a.hovercard').each do |listorious_user|
      unless lists.include?(listorious_user.attributes["username"].value)     
        TwitterList.create(:sport => sport, :user => listorious_user.attributes["username"].value)
      end
    end
	end	
	
end
