require 'rubygems'
require 'httparty'
require 'hashie'

#Define client key constant in the appropriate place depending on usage.
#CLIENT_KEY = "Your API KEY"

class Carazel
  include HTTParty
  base_uri 'dispatcher.carazel.com'

  #Find and show users

  def users
    results = self.class.get('/users', :body => {:client_key => CLIENT_KEY})
    Hashie::Mash.new(results).users
  end

  def user(id)
    results = self.class.get("/users/show?id=#{id}", :body => {:client_key => CLIENT_KEY})
    Hashie::Mash.new(results).users rescue results
  end

  #Find and show rewards as well as a given user's rewards

  def rewards(type=nil)
    if type.nil?
      results = self.class.get("/rewards/search", :body => {:client_key => CLIENT_KEY})
    else
      results = self.class.get("/rewards/search?type=type", :body => {:client_key => CLIENT_KEY})
    end
    results.collect{|r| Hashie::Mash.new(r['reward'])}
  end

  def reward(id, reward_type)
    results = self.class.get("/rewards/show?id=#{id}&reward_type=#{reward_type}", :body => {:client_key => CLIENT_KEY})
    Hashie::Mash.new(results.first['reward'])
  end

  def user_rewards(id, reward_type=nil)
    query = self.build_query_string([['id=',id],['reward_type=',reward_type]])
    results = self.class.get("/users/rewards?#{query}", :body => {:client_key => CLIENT_KEY}).first
    Hashie::Mash.new(results).rewards rescue results
  end


  #Find and show places

  def place(id)
    results = self.class.get("/places/show?id=#{id}", :body => {:client_key => CLIENT_KEY})
    Hashie::Mash.new(results.first['place']) rescue results
  end

  def places(lat,lon,term=nil)
    query = self.build_query_string([['lat=',lat],['lon=',lon],['query=',term]])
    results = self.class.get("/places/search?#{query}", :body => {:client_key => CLIENT_KEY}).collect{|r| Hashie::Mash.new(r['place'])}
  end

  #Find and show activities as well as a given user's activities

  def activities(type=nil, limit=nil)
    if type.nil? && limit.nil?
      results = self.class.get("/activities/search", :body => {:client_key => CLIENT_KEY})
    else
      query = self.build_query_string([['type=',type],['limit=',limit]])
      results = self.class.get("/activities/search?#{query}", :body => {:client_key => CLIENT_KEY})
    end
    activities = results.collect{|r| Hashie::Mash.new(r['activity'])}
  end

  def activity(id)
    results = self.class.get("/activities/show?id=#{id}", :body => {:client_key => CLIENT_KEY})
    Hashie::Mash.new(results.first['activity'])
  end

  def user_activities(id, since, activity_type=nil)
    query = self.build_query_string([['id=',id],['since=',since],['activity_type=',activity_type]])
    results = self.class.get("/users/activities?#{query}", :body => {:client_key => CLIENT_KEY})
    Hashie::Mash.new(results[0]).activities rescue results
  end

  #Find and show lbs checkins as well as a given user's lbs checkins

  def checkins(id=nil, since=nil, offset=nil)
    query = self.build_query_string([['user_id=',id],['since=',since],['offset=',offset]])
    results = self.class.get("/lbs_checkins/search?#{query}", :body => {:client_key => CLIENT_KEY}).collect{|r| Hashie::Mash.new(r['lbs_checkin'])}
  end

  def checkin(id)
    results = self.class.get("/lbs_checkins/show?id=#{id}", :body => {:client_key => CLIENT_KEY})
    Hashie::Mash.new(results.first['lbs_checkin'])
  end

  def user_checkins(id, since=nil, offset=nil)
    query = self.build_query_string([['user_id=',id],['since=',since],['offset=',offset]])
    results = self.class.get("/lbs_checkins/search?#{query}", :body => {:client_key => CLIENT_KEY}).collect{|r| Hashie::Mash.new(r['lbs_checkin'])}
  end

  #Update a users info

  def update_user(id, email=nil, mobile_number=nil, zip=nil, delivery_sms=nil, delivery_email=nil, birth_date=nil)
    result = self.class.post("/users/update", :body => {:client_key => CLIENT_KEY, :id => id, :email => email, :mobile_number => mobile_number, :zip => zip, :delivery_sms => delivery_sms, :delivery_email => delivery_email, :age => birth_date})
  end

  def create_user(email=nil, mobile_number=nil, zip=nil, delivery_sms=nil, delivery_email=nil, birth_date=nil)
    result = self.class.post("/users/create", :body => {:client_key => CLIENT_KEY, :email => email, :mobile_number => mobile_number, :zip => zip,  :delivery_sms => delivery_sms, :delivery_email => delivery_email, :age => birth_date})
  end

  #Build query string for queries with multiple combinations of values

  def build_query_string(variables)
    variables.reject{|v| v[1].nil?}.collect{|r| r.join('')}.join('&')
  end
end

