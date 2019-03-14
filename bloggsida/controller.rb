require 'sinatra'
require 'sqlite3'
require 'slim'
require 'bcrypt'
require_relative 'model.rb'
enable :sessions

configure do
    set :secured_route, ["/edit", "/delete/:id", "/createblog", "/edit/:id", "/newpost", "/myblog"]
end

before do
    if settings.secured_route.any? { |elem| request.path.start_with?(elem)}
        if session[:account]
        else
            halt 403
        end
    end
end

get('/') do
    slim(:home)
end

get('/login') do
    slim(:login)
end

post('/login') do
    loggedin = login(params)
    if loggedin == true
        session[:account] = params["Username"]
        redirect('/')
    else
        redirect('/loginfail')
    end
end

get('/loginfail') do
    slim(:loginfail)
end

get('/signup') do
    slim(:signup)
end

post('/signup') do
    signup = register(params)
    if signup == true
        redirect('/')
    else
        redirect('/signup')
    end
end

get('/profile') do
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    info = db.execute('SELECT Namn,Mail FROM Användare WHERE Namn=?', session[:account])
    slim(:profil, locals:{user:info})
end

get('/blogs') do
    blogs = bloggar()
    slim(:blogs, locals:{lista:blogs})
end

get('/blogs/:titel') do
    blog, inlägg = blogg(params)
    if blog == false
        halt 404
    else
        slim(:blog, locals:{lista:inlägg, blogg:blog})
    end
end

get('/myblog') do
    inlägg, session[:blog] = minblogg(session[:account])
    if inlägg == false
        halt 403
    else
        slim(:myblog, locals:{lista:inlägg})
    end
end

get('/edit/:id') do
    inlägg = edit(session[:blog], session[:account], params)
    if inlägg == false
        halt 403
    else
        slim(:editpost, locals:{post:inlägg})
    end
end

post('/edit/:id') do
    updatepost(params)
    redirect('/myblog')
end

post('/delete/:id') do
    deletepost(params)
    redirect('/myblog')
end

post('/createblog') do
    createblog(params, session[:account])
    redirect('/myblog')
end

post('/newpost') do
    newpost(params, session[:account])
    redirect('/myblog')
end

post('/logout') do
    session[:account] = nil
    session[:blog] = nil
    redirect('/')
end

error 404 do
    "Page not found"
end

error 403 do
    "Forbidden action"
end