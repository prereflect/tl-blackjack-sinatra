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
  session[:cash] = 500
  redirect '/bet'
end

get '/bet' do
  erb :bet
end
