require 'test_helper'
require 'digest/sha1'
require 'bcrypt'

Sham.define do 
 Sham.name { Faker::Lorem.words(1) }
 Sham.email { Faker::Internet.email }
 Sham.sentence { Faker::Lorem.sentence }
end

Game.blueprint do
  date 1.hour.from_now
  time 1.hour.from_now
  name {Sham.name}
  league { (Sport.make).short }
  home_team { (Team.make).resource }
  away_team { (Team.make).resource }
  game_datetime 1.hour.from_now
  resource_text {Sham.name}
end

Game.blueprint(:ncaaf) do
  date 2.hours.from_now
  time 2.hours.from_now
  name "Colorado Buffaloes @ Oklahoma St Cowboys"
  league "ncaaf"
  home_team "team://ncaa_football/oklahoma_st_cowboys"
  away_team "team://ncaa_football/colorado_buffaloes"
  game_datetime 2.hours.from_now
  resource_text "event://20091119ncaafoklast----0"
end

Game.blueprint(:nfl) do
  date 2.hours.from_now
  time 2.hours.from_now
  name "Denver Broncos @ SD Chargers"
  league "nfl"
  home_team "team://nfl/sd_chargers"
  away_team "team://nfl/denver_broncos"
  game_datetime 2.hours.from_now
  resource_text "event://20091019nfl--sandiego--0"
end

Game.blueprint(:world_cup) do
  date 1.hour.from_now
  time 1.hour.from_now
  name "Spain @ Netherlands"
  league "soccer"
  home_team "Netherlands"
  away_team "Spain"
  status "Fixture"
  game_datetime 1.hour.from_now
  openfooty_match_id 881633
  openfooty_home_team_id 1552
  openfooty_away_team_id 2137
  openfooty_league_id 72
  openfooty_league "World Cup"
  openfooty_status "Fixture" 
end

User.blueprint do
  username {(0...8).map{65.+(rand(25)).chr}.join.downcase}
  email {Sham.email}
  crypted_password BCrypt::Password.create(Sham.name)
  bio {Sham.sentence}
end

User.blueprint(:fail) do
  username "phu"
  email ""
end

User.blueprint(:johnny) do
  username "johnny"
  email "johnny@email.com"
  password "testing1"
  bio {Sham.sentence}
end

User.blueprint(:johnny2) do
  username "johnny2"
  email "johnny2@email.com"
  password "testing1"
  bio {Sham.sentence}
end

PrivateGameroom.blueprint do
  game { Game.make }
  login { Sham.name }
  user { User.make }
  gameroom_key SecureRandom.hex(14)
end

PrivateGameroom.blueprint(:no_login) do
  login ""
  game { Game.make }
  user { User.make }
  gameroom_key SecureRandom.hex(14)
end

PrivateUpdate.blueprint do
  user { User.make }
  private_gameroom { PrivateGameroom.make }
  content { Sham.sentence }
end

Update.blueprint do
  user { User.make }
  content { Sham.sentence }
  source 0
  game { Game.make }
  sourcename "TickrTalk"
  date_created { Time.now }
end

Update.blueprint(:world_cup) do
  user { User.make }
  content { Sham.sentence }
  source 0
  game { Game.make(:world_cup) }
  sourcename "TickrTalk"
  date_created { Time.now }
end

Sport.blueprint do
  name {Sham.name}
  short {Sham.name}
end

Sport.blueprint(:nfl) do
  name "football"
  short "nfl"
end

Sport.blueprint(:ncaaf) do
  name "ncaa_football"
  short "ncaaf"
end

Sport.blueprint(:ncaab) do
  name "ncaa_basketball"
  short "ncaab"
end

Sport.blueprint(:mlb) do
  name "baseball"
  short "mlb"
end

Sport.blueprint(:soccer) do
  name "soccer"
  short "soccer"
end

Team.blueprint do
  sport { Sport.make }
  team_name {Sham.name}
  team {Sham.name}
  mascot {Sham.name}
  league {Sham.name}
  resource {Sham.name}
  resource_path {Sham.name}
end

Team.blueprint(:osu) do
  sport { Sport.make(:ncaaf) }
  team_name "Oklahoma St Cowboys"
  team "Oklahoma St"
  mascot "Cowboys"
  league "ncaaf"
  resource "team://ncaa_football/oklahoma_st_cowboys"
  resource_path "/ncaa_football/oklahoma_st_cowboys"
end

Team.blueprint(:buffs) do
  sport { Sport.make(:ncaaf) }
  team_name "Colorado Buffaloes"
  team "Colorado"
  mascot "Buffaloes"
  league "ncaaf"
  resource "team://ncaa_football/colorado_buffaloes"
  resource_path "/ncaa_football/colorado_buffaloes"
end

Team.blueprint(:chargers) do
  sport { Sport.make(:nfl) }
  team_name "San Diego Chargers"
  team "San Diego"
  mascot "Chargers"
  league "nfl"
  resource "team://nfl/sd_chargers"
  resource_path "/nfl/sd_chargers"
end

Team.blueprint(:broncos) do
  sport { Sport.make(:nfl) }
  team_name "Denver Broncos"
  team "Denver"
  mascot "Broncos"
  league "nfl"
  resource "team://nfl/denver_broncos"
  resource_path "/nfl/denver_broncos"
end

Team.blueprint(:spain) do
  sport { Sport.make(:soccer) }
  team_name "Spain"
  team "Spain"
  mascot "Spain"
  league "soccer"
  openfooty_team_id 2137
  openfooty_team "Spain"
  openfooty_league_id 72
  openfooty_league "world cup"
  badge "http://www.footytube.com/channels/chan_thumbs/lrg/4-spain-2137.gif"
end

Team.blueprint(:netherlands) do
  sport { Sport.make(:soccer) }
  team_name "Netherlands"
  team "Netherlands"
  mascot "Netherlands"
  league "soccer"
  openfooty_team_id 1552
  openfooty_team "Netherlands"
  openfooty_league_id 72
  openfooty_league "world cup"
  badge "http://www.footytube.com/channels/chan_thumbs/lrg/4-netherlands-1552.gif"
end

Fan.blueprint do
  user { User.make }
  team { Team.make }
end

Follow.blueprint do
  follower { User.make }
  followed { User.make }
end