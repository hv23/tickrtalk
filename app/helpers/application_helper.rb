# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def linkup_mentions(text)
    text.gsub!(/@([\w]+)(\W)?/, '@<a href="/users/\1" target="_blank">\1</a>\2')
    text
  end
  
  def linkup_twitter_mentions(text)
    text.gsub!(/@([\w]+)(\W)?/, '<a href="http://twitter.com/\1" target="_blank">@\1</a>\2')
    text
  end
end
