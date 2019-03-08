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
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    blogs = db.execute('SELECT Titel,Ägare FROM Bloggar')
    slim(:blogs, locals:{lista:blogs})
end

get('/blogs/:titel') do
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    blog = db.execute('SELECT Titel,Ägare,Id FROM Bloggar WHERE Titel=?', params["titel"])
    if blog == []
        redirect('/404')
    end
    inlägg = db.execute('SELECT Titel,Info,BildLänk FROM Inlägg WHERE BloggId=? ORDER BY Id DESC', blog[0]["Id"])
    slim(:blog, locals:{lista:inlägg, blogg:blog})
end

get('/myblog') do
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    if session[:account] != nil
        blog = db.execute('SELECT Titel,Id FROM Bloggar WHERE Ägare=?', session[:account])
        inlägg = []
        if blog != []
            session[:blog] = blog
            inlägg = db.execute('SELECT Titel,Info,BildLänk,Id FROM Inlägg WHERE BloggId=? ORDER BY Id DESC', blog[0]["Id"])
        end
    else
        redirect('/nologin')
    end
    slim(:myblog, locals:{lista:inlägg})
end

get('/edit/:id') do
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    inlägg = db.execute('SELECT Titel,Info,BildLänk,Id,BloggId FROM Inlägg WHERE Id=? ORDER BY Id DESC', params["id"])
    if session[:blog] == nil
        session[:blog] = db.execute('SELECT Id FROM Bloggar WHERE Ägare=?', session[:account])
        if session[:blog] == []
            redirect('/noaccess')
        end
    end
    if session[:blog][0]["Id"] != inlägg[0]["BloggId"]
        redirect('/noaccess')
    end
    slim(:editpost, locals:{post:inlägg})
end

post('/edit/:id') do
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    db.execute('UPDATE Inlägg SET Titel=?,Info=?,BildLänk=? WHERE Id=?', params["Title"], params["Info"], params["Img"], params["id"])
    redirect('/myblog')
end

post('/delete/:id') do
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    db.execute('DELETE FROM Inlägg WHERE Id=?', params["id"])
    redirect('/myblog')
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
    if params["Img"] == ""
        params["Img"] = nil
    end
    db.execute('INSERT INTO Inlägg(Titel, Info, BloggId, BildLänk) VALUES(?, ?, ?, ?)', params["Title"], params["Info"], id[0]["Id"], params["Img"])
    redirect('/myblog')
end

post('/logout') do
    session[:account] = nil
    session[:blog] = nil
    redirect('/')
end