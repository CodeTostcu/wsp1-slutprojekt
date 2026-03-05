require 'debug'
require "awesome_print"

require 'sinatra'
require 'securerandom'

class App < Sinatra::Base

    setup_development_features(self)

    def db
      return @db if @db
      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end

    get '/' do
      redirect('/recipes')
    end

    get '/recipes' do
      @recipes = db.execute('SELECT * FROM recipes')
      p @recipes
      erb(:"recipes/index")
    end

    get '/recipes/new' do
      erb(:"recipes/new")
    end 

    post '/recipes' do
      p params 
      name = params["recipe_name"]
      description = params["recipe_description"]
      time = params["recipe_time"]
      category = params["recipe_category"]

      db.execute('INSERT INTO recipes(name, description, time, category) VALUES(?,?,?,?)', [name, description, time, category.to_i])
      redirect("/recipes")
    end 

    get '/recipes/:id' do | id |
      @recipes = db.execute('SELECT * FROM recipes WHERE id=?', [id.to_i]).first
      erb(:"recipes/show")
    end

    post '/recipes/:id/delete' do | id |
      db.execute('DELETE FROM recipes WHERE id=?', [id.to_i])
      redirect("/recipes") 
    end

    get '/recipes/:id/edit' do | id |
      @recipes = db.execute('SELECT * FROM recipes WHERE id=?', [id.to_i]).first
      erb(:"recipes/edit")
    end

    post "/recipes/:id/update" do | id |
      name = params["recipe_name"]
      description = params["recipe_description"]
      time = params["recipe_time"]
      category = params["recipe_category"]

      db.execute('Update recipes Set name=?, description=?, time=?, category=? Where id=?', [name, description, time, category, id])
      redirect("/recipes")
    end


    #log in

    configure do
      enable :sessions
      set :session_secret, SecureRandom.hex(64)
    end
  
    before do
      if session[:user_id]
        @current_user = db.execute("SELECT * FROM users WHERE id = ?", session[:user_id]).first
        ap @current_user
      end
    end
  
    get '/' do
      erb(:index)
    end
  
    get '/admin' do
      if session[:user_id]
        erb(:"admin/index")
      else
        ap "/admin : Access denied."
        status 401
        redirect '/acces_denied'
      end
    end
  
    get '/acces_denied' do
      erb(:acces_denied)
    end
  
    get '/login' do
      erb(:login)
    end
  
    post '/login' do
      request_username = params[:username]
      request_plain_password = params[:password]
  
      user = db.execute("SELECT * FROM users WHERE username = ?", request_username).first
  
      unless user
        ap "/login : Invalid username."
        status 401
        redirect '/acces_denied'
      end
  
      db_id = user["id"].to_i
      db_password_hashed = user["password"].to_s
  
      bcrypt_db_password = BCrypt::Password.new(db_password_hashed)
    
      if bcrypt_db_password == request_plain_password
        ap "/login : Logged in -> redirecting to admin"
        session[:user_id] = db_id
        redirect '/admin'
      else
        ap "/login : Invalid password."
        status 401
        redirect '/acces_denied'
      end
    end
  
    post '/logout' do
      ap "Logging out"
      session.clear
      redirect '/'
    end
  
    get '/users/new' do
      erb(:"users/new")
    end

end
