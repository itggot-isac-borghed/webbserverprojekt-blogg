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

post('/login') do
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    password = db.execute('SELECT Lösenord FROM Användare WHERE Namn=?', params["Username"])
    if password != []
        if (BCrypt::Password.new(password[0][0]) == params["Password"]) == true
            session[:account] = params["Username"]
            redirect('/')
        else
            redirect('/loginfail')
        end
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
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    if params["Username"] != "" && params["Password"]
        db.execute('INSERT INTO Användare(Namn, Lösenord, Mail) VALUES (?, ?, ?)', params["Username"], BCrypt::Password.create(params["Password"]), params["Mail"])
        redirect('/login')
    else
        redirect('/signup')
    end
end

get('/blogs') do
    slim(:blogs)
end

get('/myblog') do
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    titel = db.execute('SELECT Titel FROM Bloggar WHERE Ägare=?', session[:account])
    inlägg=[]
    if titel != []
        id = db.execute('SELECT Id FROM Bloggar WHERE Ägare=?', session[:account])
        session[:blog] = titel
        inlägg = db.execute('SELECT Titel,Info FROM Inlägg WHERE BloggId=? ORDER BY Id DESC', id[0]["Id"])
    end
    slim(:blog, locals:{lista:inlägg})
end

post('/createblog') do
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    db.execute('INSERT INTO Bloggar(Titel, Ägare) VALUES(?, ?)', params["Title"], session[:account])
    redirect('/myblog')
end

post('/newpost') do
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    id = db.execute('SELECT Id FROM Bloggar WHERE Ägare=?', session[:account])
    db.execute('INSERT INTO Inlägg(Titel, Info, BloggId) VALUES(?, ?, ?)', params["Title"], params["Info"], id[0]["Id"])
    redirect('/myblog')
end

post('/logout') do
    session[:account] = nil
    redirect('/')
end