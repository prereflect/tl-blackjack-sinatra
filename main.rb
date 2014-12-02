require 'sinatra'

set :sessions, true

get '/' do
  erb :index
end

