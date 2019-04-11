require 'byebug'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'

def connect_db()
    db = SQLite3::Database.new('db/store.db')
    db.results_as_hash = true
    return db
end

def register(params)

    if params["Username"] && params["Email"] && params["Password"]

        db = connect_db()
        hashat_password = BCrypt::Password.create(params["Password"])

        db.execute("INSERT INTO users(Username, Email, Password) VALUES(?, ?, ?)", params["Username"], params["Email"], hashat_password)
        return true
    else
        return false
    end
end

def login(params)
    db = connect_db()
    user_info = db.execute("SELECT Password, User_Id FROM Users WHERE Username = ?",params["Username"])
    username = params["Username"] 
    if (BCrypt::Password.new(user_info.first["Password"]) == params["Password"]) == true
        user_id = user_info.first["User_Id"]
        return [username, user_id]
    else
        return false
    end
end