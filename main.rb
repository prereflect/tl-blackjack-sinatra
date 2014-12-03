require 'sinatra'

set :sessions, true

get '/' do
  erb :index
end

get '/form' do
  erb :form
end

post '/getname' do
  session[:username] = params[:username]
  redirect '/bet'
end

get '/bet' do
  erb :bet
end
