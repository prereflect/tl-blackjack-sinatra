require 'sinatra'

set :sessions, true

get '/' do
  "Hello Sinatra!"
end

get '/template' do
  erb :mytemplate
end

get '/nested' do
  erb :'users/profile'
end
