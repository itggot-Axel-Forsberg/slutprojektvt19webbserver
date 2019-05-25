require 'byebug'
require 'sinatra'
require 'slim'
require 'sqlite3'
require 'bcrypt'
module MyModule

    # Connects to the database and then returns it.
    # 
    # return [Database] containing all the data in database.
    def connect_db()
        db = SQLite3::Database.new('db/store.db')
        db.results_as_hash = true
        return db
    end
    
    # Creates a new account unless the either of the params are empty.
    # 
    # @param [Hash] params form data from register.
    # @option params [String] Username, The username
    # @option params [String] Email, The users email
    # @option params [String] Password, The users password
    #
    # @return [Boolean] if register is successful
    #
    # @return [Boolean] if register is not successful
    def register(params)
        unless params["Username"] == "" or params["Email"] == "" or params["Password"] == ""
            if params["Username"] && params["Email"] && params["Password"]
                
                db = connect_db()
                hashat_password = BCrypt::Password.create(params["Password"])

                db.execute("INSERT INTO users(Username, Email, Password) VALUES(?, ?, ?)", params["Username"], params["Email"], hashat_password)
                return true
                
            end
        end
        return false
    end

    # Logs the user in to an existing account unless either of the params are empty.
    #
    # @param [Hash] params form data from register.
    # @option params [String] Username, The username
    # @option params [String] Password, The users password
    #
    # @return [Array] containing username, userid and boolean, if login is successful 
    #
    # @return [Boolean] if login is unsuccessful
    def login(params)
        db = connect_db()
        user_info = db.execute("SELECT Password, User_Id FROM users WHERE Username = ?",params["Username"])
        username = params["Username"] 
        unless username == "" or params["Password"] == ""
            if (BCrypt::Password.new(user_info.first["Password"]) == params["Password"]) == true
                user_id = user_info.first["User_Id"]
                return [username, user_id, true]
            end
        end
        return false
    end

    # Creates a new order unless there already is an active order and returns the orderid of the order.
    #
    # @param [Integer] User_Id, The id of the user 
    # 
    # @return [Integer] orderid["Order_Id"], the id of the active order.
    def new_order(user_id)
        db = connect_db()
        status = "unpaid"
        if db.execute("SELECT * FROM orders WHERE User_Id = ? AND Status = ?", user_id, status) == []
            
            db.execute("INSERT INTO orders(User_Id, Price, Status) VALUES(?, 0, ?)", user_id, status)
        end
        orderid = db.execute("SELECT Order_Id FROM orders WHERE User_Id = ? AND Status = ?", user_id, status).first
        return orderid["Order_Id"]
    end

    # Adds an item, price and amount to an existing order unless the amount is 0 or lower.
    #
    # @param [Hash] params form data from store page.
    # @option params [Integer] Amount, the amount of a specific product.
    # @option params [String] Item_Id, The id of the product that is to be added.
    #
    # @return [Boolean] if product is added.
    #
    # @return [Boolean] if product is not added.
    def add_orderitem(params, user_id)
        status = "unpaid"
        if params[:amount].to_i > 0
            db = connect_db()
            status = "unpaid"
            order = db.execute("SELECT Order_Id, Price FROM orders WHERE User_Id = ? AND Status = ?", user_id, status).first
            new_item = db.execute("SELECT Item_Name, Price FROM items WHERE Item_Id = ?", params[:item_id]).first
            price = new_item["Price"] * params[:amount].to_i
            db.execute("INSERT INTO orderitem(Order_Id, Item_Id, Order_Name, Price, Amount) VALUES(?, ?, ?, ?, ?)", order["Order_Id"], params[:item_id].to_i, new_item["Item_Name"], price, params[:amount].to_i)
            order["Price"] += new_item["Price"] * params[:amount].to_i
            db.execute("UPDATE orders SET Price=? WHERE User_Id = ? AND Status = ?", order["Price"], user_id, status)
            return true
        else
            return false
        end
    end

    # 
    #
    #
    def item_info()
        db = connect_db()
        items = db.execute("SELECT * FROM items")
        return items
    end

    def orderinfo(orderid)
        db = connect_db()
        orderinfo = db.execute("SELECT * FROM orderitem WHERE Order_Id = ?", orderid)
        return orderinfo
    end

    def checkout(user_id)
        db = connect_db()
        status_unpaid = "unpaid"
        status_paid = "paid"
        db.execute("UPDATE orders SET Status = ? WHERE User_Id = ? AND Status = ?", status_paid, user_id, status_unpaid)
    end

    def user_orders(user_id)
        db = connect_db()
        if db.execute("SELECT * FROM orders WHERE User_Id = ?", user_id) == []
            user_orders = []
        else
            user_orders = db.execute("SELECT Date, Status, Price, Order_Id FROM orders WHERE User_Id = ?", user_id)
        end
        return user_orders
    end

    def delete_order(orderid)
        db = connect_db()
        db.execute("DELETE FROM orders WHERE Order_Id = ?", orderid)
        db.execute("DELETE FROM orderitem WHERE Order_Id = ?", orderid)
    end

    def delete_orderitem(item_id, orderid, userid)
        db = connect_db()
        total = 0
        status = "unpaid"
        db.execute("DELETE FROM orderitem WHERE Item_Id = ? AND Order_Id = ?", item_id, orderid)
        price = db.execute("SELECT Price FROM orderitem WHERE Order_Id = ?", orderid)
        unless price == nil
            price.each do |prices|
                total += prices["Price"]
            end
        end
        db.execute("UPDATE orders SET Price=? WHERE User_Id = ? AND Status = ?", total, userid, status)
    end
end