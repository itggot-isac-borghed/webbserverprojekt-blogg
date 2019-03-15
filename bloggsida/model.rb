def login(params)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    password = db.execute('SELECT Lösenord FROM Användare WHERE Namn=?', params["Username"])
    if password != []
        if (BCrypt::Password.new(password[0][0]) == params["Password"]) == true
            return true
        else
            return false
        end
    else
        return false
    end
end

def register(params)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    if params["Username"] != "" && params["Password"]
        db.execute('INSERT INTO Användare(Namn, Lösenord, Mail) VALUES (?, ?, ?)', params["Username"], BCrypt::Password.create(params["Password"]), params["Mail"])
        return true
    else
        return false
    end
end

def bloggar()
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    blogs = db.execute('SELECT Titel,Ägare FROM Bloggar')
    blogs
end

def blogg(params)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    blog = db.execute('SELECT Titel,Ägare,Id FROM Bloggar WHERE Titel=?', params["titel"])
    if blog == []
        return false, false
    end
    inlägg = db.execute('SELECT Titel,Info,BildLänk FROM Inlägg WHERE BloggId=? ORDER BY Id DESC', blog[0]["Id"])
    return blog, inlägg
end

def minblogg(account)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    blog = db.execute('SELECT Titel,Id FROM Bloggar WHERE Ägare=?', account)
    inlägg = []
    if blog != []
        inlägg = db.execute('SELECT Titel,Info,BildLänk,Id FROM Inlägg WHERE BloggId=? ORDER BY Id DESC', blog[0]["Id"])
        return inlägg, blog
    end
end

def edit(blog, account, params)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    inlägg = db.execute('SELECT Titel,Info,BildLänk,Id,BloggId FROM Inlägg WHERE Id=? ORDER BY Id DESC', params["id"])
    if blog == nil
        blog = db.execute('SELECT Id FROM Bloggar WHERE Ägare=?', account)
        if blog == []
            return false
        end
    end
    if blog[0]["Id"] != inlägg[0]["BloggId"]
        return false
    end
    return inlägg
end

def updatepost(params)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    if params[:file] != nil
        @filename = params[:file][:filename]
        file = params[:file][:tempfile]
        File.open("./public/#{@filename}", 'wb') do |f|
            f.write(file.read)
        end
    else
        @filename = nil
    end
    db.execute('UPDATE Inlägg SET Titel=?,Info=?,BildLänk=? WHERE Id=?', params["Title"], params["Info"], @filename, params["id"])
end

def deletepost(params)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    db.execute('DELETE FROM Inlägg WHERE Id=?', params["id"])
end

def createblog(params, account)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    db.execute('INSERT INTO Bloggar(Titel, Ägare) VALUES(?, ?)', params["Title"], account)
end

def newpost(params, account)
    db = SQLite3::Database.new("db/databas.db")
    db.results_as_hash = true
    id = db.execute('SELECT Id FROM Bloggar WHERE Ägare=?', account)
    if params[:file] != nil
        @filename = params[:file][:filename]
        file = params[:file][:tempfile]
        File.open("./public/#{@filename}", 'wb') do |f|
            f.write(file.read)
        end
    else
        @filename = nil
    end
    db.execute('INSERT INTO Inlägg(Titel, Info, BloggId, BildLänk) VALUES(?, ?, ?, ?)', params["Title"], params["Info"], id[0]["Id"], @filename)
end