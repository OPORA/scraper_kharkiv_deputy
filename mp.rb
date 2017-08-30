require 'sinatra'
require 'sinatra/json'
require_relative 'lib/people'
set :protection, except: [:json_csrf]

get '/' do
  hash =[]
  people = People.all
  people.map{|mp| hash << {deputy_id: mp.deputy_id, full_name: mp.full_name, first_name: mp.first_name, middle_name: mp.middle_name,  last_name: mp.last_name, faction: mp.faction, okrug: mp.okrug, photo_url: mp.photo_url, start_date: mp.start_date, end_date: mp.end_date}}
  json hash
end