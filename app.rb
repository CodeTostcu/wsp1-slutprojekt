require 'debug'
require "awesome_print"
require 'sinatra'
require 'securerandom'
require 'bcrypt'

require_relative 'models/recipe'
require_relative 'models/user'
require_relative 'models/group'


# Main Sinatra application handling users, recipes and groups.
# Provides authentication, CRUD for recipes, and group membership.
class App < Sinatra::Base
    setup_development_features(self)

    FAILED_LOGINS = {}
    COOLDOWN_TIME = 30
    MAX_ATTEMPTS = 3
  
    ##
    # Redirect root to login page
    #
    # @return [void]
    get '/' do
      redirect('/login')
    end

    ##
    # List all recipes
    #
    # @return [ERB] renders recipes/index
    get '/recipes' do
      @recipes = Recipes.all();
      p @recipes
      erb(:"recipes/index")
    end

    ##
    # Show form for creating a new recipe
    #
    # @return [ERB] renders recipes/new
    get '/recipes/new' do
      erb(:"recipes/new")
    end 

    ##
    # Show form for creating a new recipe
    #
    # @return [ERB] renders recipes/new
    post '/recipes' do
      p params 
      name = params["recipe_name"]
      description = params["recipe_description"]
      time = params["recipe_time"]
      category = params["recipe_category"]
      userid = session[:user_id]

      
      @new = Recipes.create(name, description, time, category, userid);
      p @new
      redirect("/recipes")
    end 

    ##
    # Create a new recipe
    #
    # @param [String] recipe_name
    # @param [String] recipe_description
    # @param [String] recipe_time
    # @param [String] recipe_category
    # @return [Redirect]
    get '/recipes/:id' do | id |
      @recipes = Recipes.find(id);
      erb(:"recipes/show")
    end

    ##
    # Delete a recipe
    #
    # @param [Integer] id
    # @return [Redirect]
    post '/recipes/:id/delete' do | id |
      @delete = Recipes.delete(id);
      p @delete
      redirect("/recipes") 
    end

    ##
    # Show edit form for recipe
    #
    # @param [Integer] id
    # @return [ERB] renders recipes/edit
    get '/recipes/:id/edit' do | id |

      @recipes = Recipes.find(id);
      erb(:"recipes/edit")
    end

    ##
    # Update a recipe
    #
    # @param [Integer] id
    # @return [Redirect]
    post "/recipes/:id/update" do | id |
      name = params["recipe_name"]
      description = params["recipe_description"]
      time = params["recipe_time"]
      category = params["recipe_category"]

      @update = Recipes.update(name, description, time, category, id)
      p @update
      redirect("/recipes")
    end

    configure do
      enable :sessions
      set :session_secret, SecureRandom.hex(64)
    end
    
    ##
    # Set current user before each request if logged in
    #
    # @return [void]
    before do
      if session[:user_id]
        @current_user = Users.find(session[:user_id]);
        ap @current_user
      end
    end
  
    get '/' do
      erb(:index)
    end
    
    ##
    # Admin dashboard (requires login)
    #
    # @return [ERB] renders admin/index or redirects
    get '/admin' do
      if session[:user_id]
        erb(:"admin/index")
      else
        ap "/admin : Access denied."
        status 401
        redirect '/acces_denied'
      end
    end
    
    ##
    # Access denied page
    #
    # @return [ERB]
    get '/acces_denied' do
      erb(:acces_denied)
    end
    
    ##
    # Login form
    #
    # @return [ERB]
    get '/login' do
      erb(:login)
    end

    ##
    # Login authenticater
    #
    # Authenticates a user using username/password with BCrypt.
    # Applies IP-based rate limiting with a cooldown after max failed attempts.
    #
    # @param params[:username] [String] login username
    # @param params[:password] [String] plaintext password
    # @return [String] redirect to /admin on success, /acces_denied on failure,
    # or HTTP 429 if IP is temporarily blocked
    #
    # Tracks failed attempts per IP in FAILED_LOGINS
    post '/login' do
      ip = request.ip
      now = Time.now

      FAILED_LOGINS[ip] ||= { count: 0, last_failed: nil }

      record = FAILED_LOGINS[ip]

      if record[:count] >= MAX_ATTEMPTS
        if record[:last_failed] && (now - record[:last_failed]) < COOLDOWN_TIME
          remaining = COOLDOWN_TIME - (now - record[:last_failed]).to_i
          ap "/login : IP blocked for #{remaining} seconds"
          status 429
          return "Too many failed attempts. Try again in #{remaining} seconds."
        else
          record[:count] = 0
        end
      end

      request_username = params[:username]
      request_plain_password = params[:password]

      user = Users.all(request_username)

      unless user
        record[:count] += 1
        record[:last_failed] = now
        ap "/login : Invalid username."
        status 401
        redirect '/acces_denied'
      end
  
      db_id = user["id"].to_i
      db_password_hashed = user["password"].to_s
  
      bcrypt_db_password = BCrypt::Password.new(db_password_hashed)
    
      if bcrypt_db_password == request_plain_password
        FAILED_LOGINS[ip] = { count: 0, last_failed: nil }

        ap "/login : Logged in -> redirecting to admin"
        session[:user_id] = db_id
        redirect '/admin'
      else
        record[:count] += 1
        record[:last_failed] = now
    
        ap "/login : Invalid password (attempt #{record[:count]})"
    
        status 401
        redirect '/acces_denied'
      end
    end
  
    ##
    # Logout user
    #
    # @return [Redirect]
    post '/logout' do
      ap "Logging out"
      session.clear
      redirect '/'
    end
    
    ##
    # Registration form
    #
    # @return [ERB]
    get '/users/new' do
      erb(:"users/new")
    end

    ##
    # Create user
    #
    # @param [String] user_name
    # @param [String] user_password
    # @return [Redirect]
    post '/users' do
      p params 
      username = params["user_name"]
      password = params["user_password"]

      password_hashed = BCrypt::Password.create(password)

      Users.create(username, password_hashed)
      redirect("/login")
    end 

    ##
    # Delete user account + related data
    #
    # @param [Integer] id
    # @return [Redirect]
    post '/users/:id/delete' do | id |

      Users.delete(session[:user_id])
      Recipes.delete_user(session[:user_id])
      session.clear
      redirect("/login") 
    end

    ##
    # Edit user form
    #
    # @param [Integer] id
    # @return [ERB]
    get '/users/:id/edit' do | id |
      @current_user = Users.find(session[:user_id])
      erb(:"users/edit")
    end

    ##
    # Update username
    #
    # @param [Integer] id
    # @return [Redirect]
    post "/users/:id/update" do |id|
      username = params["user_name"]
      @existing_user = Users.find_user(username, id)

      if @existing_user
        redirect "/users/#{id}/edit"
      else
        Users.update(username, id)
        redirect "/users/#{id}/edit"
      end
    end

    ##
    # List groups and memberships
    #
    # @return [ERB]
    get '/groups' do
      @groups = Groups.all()
      @user_group = Groups.find_user(session[:user_id])
      @other_group = Groups.find_group(session[:user_id])
      p @groups
      erb(:"groups/index")
    end

    ##
    # Show group page with user recipes
    #
    # @param [Integer] id
    # @return [ERB]
    get '/groups/:id' do |id|
      @user_recipes = Groups.find_user_in_group(id)
      erb(:"groups/show")
    end

    ##
    # Join a group
    #
    # @param [Integer] id
    # @return [Redirect]
    post '/groups/:id/join' do |id|
      @join_group = Groups.join(session[:user_id], id)
      redirect("/groups")
    end 
end
