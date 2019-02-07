require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
enable :sessions

get('/') do
    slim(:home)
end

get('/login') do
    slim(:login)
end

get('/blogs') do
    slim(:blogs)
end

get('/blogs/:owner') do
    slim(:blog)
end