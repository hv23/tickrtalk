require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  should 'create a user' do
    user = User.make
    assert_match /\w/, user.username
    assert_not_nil user.bio
  end
  
  should 'not create a user' do
    user = User.new(User.plan(:fail))
    user.valid?
    assert_equal "must be at least 4 letters", user.errors[:username].first
    assert_equal "can't be empty", user.errors[:email].first
  end

  test "authorize false if missing twitter_token and twitter_secret" do
    @user = User.new
    assert_equal(false, @user.authorized?)
  end

  test "authorize false if missing twitter_token" do
    @user = User.new
    @user.twitter_token = nil
    @user.twitter_secret = 'some secret'
    assert_equal(false, @user.authorized?)
  end

  test "authorize false if missing twitter_secret" do
    @user = User.new
    @user.twitter_token = 'some token'
    @user.twitter_secret = nil
    assert_equal(false, @user.authorized?)
  end

  test "authorize true if both twitter_token and twitter_secret present" do
    @user = User.new
    @user.twitter_token = 'some token'
    @user.twitter_secret = 'some secret'
    assert_equal(true, @user.authorized?)
  end
  
  test "oauth helper" do
    user = User.new
    assert_equal(user.oauth.class, Twitter::OAuth)
  end
  
  test "authorize from access token and secret" do
    @user = User.new(:twitter_token => 'twitter_token', :twitter_secret => 'twitter_secret')
    @oauth = Twitter::OAuth.new('token', 'secret')
    assert_equal(@oauth.csecret, 'secret')
    assert_equal(@oauth.ctoken, 'token')
    @user.client
  end

  test "return twitter base object" do
    @user = User.new(:twitter_token => 'twitter_token', :twitter_secret => 'twitter_secret')
    @oauth = Twitter::OAuth.new('token', 'secret')
    assert_equal(@user.client.class, Twitter::Base)
  end
end
