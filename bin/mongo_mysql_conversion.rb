# Script from http://gist.github.com/290175

# The basic idea is that we take the existing data via ActiveRecord
# and create new documents in MongoDB using MongoMapper.
# This method is necessary as we want to keep all the associations of existing dataset
# and by the way, clean up empty columns
# We rely on models still being ActiveRecord::Base, I bet you can figure out how the look like.
# And have the newer MongoDB ones here in a module, painful as we have to set the collection_name
# Don't put a +timestamps!+ into your MongoMapper models yet because this would change the updated_at if existing
# As you see in the MongoDB models, a few loose their indepence, e.g. Source as I
# plan to add other sources besides flickr, or Page and Album which only make sense in
# their parent Website
# Photo stays independed though I'm thinking about making copies into Album and Page
# as this would allow the user to change e.g. title or tags in his photos

module MongoStream
  class Sport
    include MongoMapper::Document
    @collection_name = 'sports'
  end
  
  class Fan
    include MongoMapper::Document
    @collection_name = 'fans'
  	belongs_to :user
  	belongs_to :team
  end
  
  class GameroomCheckin
    include MongoMapper::Document
    @collection_name = 'gameroom_checkins'
    belongs_to :private_gameroom
    belongs_to :user
  end
  
  class PrivateGameroom
    include MongoMapper::Document
    @collection_name = 'private_gamerooms'
    has_many :private_updates
    has_many :gameroom_checkins
    belongs_to :user
  end
  
  class PrivateUpdate
    include MongoMapper::Document
    @collection_name = 'private_updates'
    belongs_to :user
  	belongs_to :private_gameroom
  end
  
  class Team
    include MongoMapper::Document
    @collection_name = 'teams'
    has_many :fans
  end
  
  class Update
    include MongoMapper::Document
    @collection_name = 'updates'
  	belongs_to :user
  	belongs_to :game
  end
  
  class Follow
    include MongoMapper::Document
    @collection_name = 'follow'
    belongs_to :follower, :class_name => "MongoStream::User"
    belongs_to :followed, :class_name => "MongoStream::User"
  end
  
  class User
    include MongoMapper::Document
    @collection_name = 'users'
    
    has_many :fans
  	has_many :teams , :through => :fans
  	has_many :updates
  	has_many :private_updates
  	has_many :private_gamerooms
  	has_many :gameroom_checkins

  	has_many :follows, :foreign_key => "follower_id", :class_name => "MongoStream::Follow", :dependent => :destroy
    has_many :users_followed, :through => :follows, :source => :followed

    has_many :followings, :foreign_key => "followed_id", :class_name => "MongoStream::Follow", :dependent => :destroy
    has_many :users_following, :through => :followings, :source => :follower
  end
end

class MongoMysqlConversion < ActiveRecord::Migration
  require 'mongo_mapper'
  def self.clean_attrs(object, unneeded_attributes = [])
    unneeded_attributes << 'id'
    attributes = object.attributes.dup
    # we keep the old_id for now to copy the associations much easier
    attributes['old_id'] = attributes['id']
    attributes.reject!{|k,v|unneeded_attributes.include?(k.to_s) || v.nil?}
    attributes
  end
  def self.up
    # %w(MongoStream::User MongoStream::Fan MongoStream::Follow MongoStream::Game MongoStream::GameroomCheckin MongoStream::PrivateGameroom MongoStream::PrivateUpdate MongoStream::Sport MongoStream::Team MongoStream::Update).map{|klass| instance_eval("#{klass}.delete_all") rescue nil }
    # ::User.all.each do |user|
    #   m_user = MongoStream::User.create!(clean_attrs(user))
    # 
    #   user.sources.find(:all, :limit => 10).each do |source|
    #     m_source = MongoStream::Source.new(clean_attrs(source))
    #     m_source[:user_id] = m_user.id
    #     source.photos.each do |photo|
    #       m_photo = MongoStream::Photo.create!(clean_attrs(photo))
    #       m_photo[:tags] = photo.tag_list.to_a
    #       m_photo[:source_id] = m_source.id
    #       m_photo[:user_id] = m_source.user_id
    #       m_photo.save
    #     end
    #     m_source.save
    #     m_user.sources << m_source
    #   end
    #   # With those embedded documents, never forget to save the root element!
    #   m_user.save
    # end
    # Website.all.each do |website|
    #   m_website = MongoStream::Website.create(clean_attrs(website))
    #   m_website.photos = MongoStream::Photo.all(:conditions => {:old_id => website.photo_ids})
    #   m_website.user_ids = MongoStream::User.all(:conditions => {:old_id => website.user_ids}).collect(&:_id)
    #   website.albums.each do |album|
    #     m_website.albums << MongoStream::Album.new(clean_attrs(album, %w(website_id key_photo_id parent_id)))
    #   end
    #   website.pages.each do |page|
    #     m_website.pages << MongoStream::Page.new(clean_attrs(page, %w(website_id user_id parent_id)))
    #   end
    #   m_website.save
    # end
    # # And now again all users and update their website_ids
    # MongoStream::User.all.each do |m_user|
    #   old_website_ids = User.find(m_user.old_id).website_ids
    #   m_user.update_attribute(:website_ids, MongoStream::Website.all(:conditions => {:old_id => old_website_ids}).collect(&:id))
    # end

    # The best is to clean up and remove the old_ids via the mongo console, there for mongo 1.3+
    #   db.photos.update({}, { $unset : { old_id : 1}}, false, true )
    #   db.websites.update({}, { $unset : { old_id : 1, 'albums.old_id': 1, 'pages.old_id': 1}}, false, true )
    #   db.users.update({}, { $unset : { old_id : 1}}, false, true )
    
  end

  def self.down
  end
end
