require 'rubygems'
require 'httparty'
require 'hashie'

class Carazel
  include HTTParty
  base_uri 'dispatcher.carazel.com'

  def users
    results = self.class.get('/users')
    Hashie::Mash.new(results).users
  end

  def user(id)
    results = self.class.get("/users/show?id=#{id}")
    Hashie::Mash.new(results).users rescue results
  end

  def user_rewards(id)
    results = self.class.get("/users/rewards?id=#{id}").first
    Hashie::Mash.new(results).rewards rescue results
  end

  def place(id)
    results = self.class.get("/places/show?id=#{id}")
    Hashie::Mash.new(results.first['place']) rescue results
  end

  def places(lat,lon,query=nil)
    if query.nil?
      results = self.class.get("/places/search?lat=#{lat}&lon=#{lon}")
    else
      results = self.class.get("/places/search?lat=#{lat}&lon=#{lon}&query=#{query}")
    end
    @places = []
    results.each do |result|
      r = Hashie::Mash.new(result['place'])
      @places << r
    end
    return @places
  end
end

