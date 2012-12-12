require 'digest/sha1'
require 'bcrypt'

class User
  include MongoMapper::Document
  include Paperclip
  
  key :username, String, :required => true
  key :email, String, :required => true
  key :crypted_password, String
  key :reset_password_code, String
  key :reset_password_code_until, Time
  key :date_created, Time
  key :date_createdu, Integer
  key :imageset, Integer
  key :time_zone, String
  key :bio, String
  key :avatar_file_name, String
  key :avatar_content_type, String
  key :avatar_file_size, Integer
  key :twitter_name, String
  key :twitter_token, String
  key :twitter_secret, String
  key :password_salt, String
  key :persistence_token, String
  key :perishable_token, String
  key :login_count, Integer
  key :last_login_at, Time
  key :last_login_ip, String
  key :name, String
  key :facebook_uid, String
  key :facebook_session_key, String
  key :facebook_name, String
  key :facebook_token, String
  key :replies_count, String
  key :admin, Boolean
  key :temp_contacts, String
  timestamps!
  
  RegUsername    = /\A\w[\w\.+\-_@ ]+$/
  RegEmailName   = '[\w\.%\+\-]+'
  RegDomainHead  = '(?:[A-Z0-9\-]+\.)+'
  RegDomainTLD   = '(?:[A-Z]{2}|com|org|net|gov|mil|biz|info|mobi|name|aero|jobs|museum|edu)'
  RegEmailOk     = /\A#{RegEmailName}@#{RegDomainHead}#{RegDomainTLD}\z/i
    
  # associations
	many :fans
	many :teams , :through => :fans
	many :updates
	many :private_updates
	many :private_gamerooms
	many :gameroom_checkins

  # indices
  ensure_index :username  
  
  def self.authenticate(username, secret)
    u = User.first(:conditions => {:username => username})
    u && u.authenticated?(secret) ? u : nil
  end
  
  def self.generate_gameroom_key
    gameroom_key = Digest::SHA1.hexdigest(Time.now.to_s.split(//).sort_by{rand}.join)
    gameroom_key
  end

  validates_length_of :username, :within => 4..100, :allow_blank => true, :message => "must be at least 4 letters"
  validates_format_of :username, :with => RegUsername, :allow_blank => true, :message => "must include letters, numbers, or underscore"
  
  validates_length_of :email, :within => 6..100, :allow_blank => true
  validates_format_of :email, :with => RegEmailOk, :allow_blank => true
  
  PasswordRequired = Proc.new { |u| u.password_required? }
  validates_presence_of :password, :if => PasswordRequired
  validates_confirmation_of :password, :if => PasswordRequired, :allow_nil => true
  validates_length_of :password, :minimum => 6, :if => PasswordRequired, :allow_nil => true, :message => "must at least 6 letters"

  UsernameUnique = Proc.new { |u| User.all(:order => "username").collect(&:username).include?(u.username) }
  validates_uniqueness_of :username, :if => UsernameUnique, :message => "is already taken."  
  # validate :uniqueness_of_username
  
  has_attached_file :avatar, :whiny_thumbnails => true,
    :styles => {
      :medium => "100x100#",
      :largethumb  => "90x90#",
      :mediumthumb  => "70x70#",
      :thumb  => "48x48#",
      :small  => "25x25#"
    }
    
  # Paperclip Validations
  validates_attachment_content_type :avatar, :content_type => ['image/jpeg', 'image/pjpeg', 'image/jpg', 'image/png', 'image/gif']
  
  def authenticated?(secret)
    password == secret ? true : false
  end
  
  def password
    if crypted_password.present?
      @password ||= BCrypt::Password.new(crypted_password)
    else
      nil
    end
  end
  
  def password=(value)
    if value.present?
      @password = value
      self.crypted_password = BCrypt::Password.create(value)
    end
  end
  
  def email=(new_email)
    new_email.downcase! unless new_email.nil?
    write_attribute(:email, new_email)
  end
  
  def password_required?
    crypted_password.blank? || !password.blank?
  end
  
  def set_password_code!
    seed = "#{email}#{Time.now.to_s.split(//).sort_by {rand}.join}"
    self.reset_password_code_until = 1.day.from_now
    self.reset_password_code = Digest::SHA1.hexdigest(seed)
    save!
  end

  def authorized?
    twitter_token.present? && twitter_secret.present?
  end
  
  def facebook_oauth
    @facebook_oauth = FBGraph::Client.new(
        :client_id => FbConsumerConfig[RAILS_ENV]['application_id'],
        :secret_id => FbConsumerConfig[RAILS_ENV]['secret_key']
    )  
  end
  
  def facebook_authorized?
    facebook_token.present?
  end
  
  def oauth
    @oauth ||= Twitter::OAuth.new(ConsumerConfig['token'], ConsumerConfig['secret'])
  end
  
  delegate :request_token, :access_token, :authorize_from_request, :to => :oauth
  
  def client
    @client ||= begin
      oauth.authorize_from_access(twitter_token, twitter_secret)
      Twitter::Base.new(oauth)
    end
  end
  
  def facebook_login?
    facebook_session.user.name.present? && facebook_session.user.uid.present?
  end

end
