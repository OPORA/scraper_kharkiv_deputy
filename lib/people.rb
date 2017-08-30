require 'data_mapper'
require 'config'

unless ENV['RACK_ENV']
  Config.load_and_set_settings(File.dirname(__FILE__) +'/../config/secrets.yml')
end

DataMapper::Logger.new($stdout, :debug)
DataMapper.setup(:default, ENV['DATABASE_URL'] || Settings.db_url)
class People
  include DataMapper::Resource

  property :id,           Serial    # An auto-increment integer key
  property :deputy_id,      Integer
  property :first_name,   String
  property :middle_name,  String
  property :last_name,    String
  property :full_name,    Text
  property :photo_url,    Text    # A varchar type string, for short strings
  property :faction,     String
  property :okrug,        Integer
  property :start_date,     Date
  property :end_date,     Date
  property :created_at,   DateTime  # A DateTime, for any date you might like.
  property :updated_at,   DateTime
end
DataMapper.finalize


