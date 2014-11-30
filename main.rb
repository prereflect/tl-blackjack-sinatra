require 'sinatra'

set :sessions, true

get '/' do
  "Hello Sinatra!"
end

