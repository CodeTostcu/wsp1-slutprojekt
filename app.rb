require 'debug'
require "awesome_print"

class App < Sinatra::Base

    setup_development_features(self)

    def db
      return @db if @db
      @db = SQLite3::Database.new(DB_PATH)
      @db.results_as_hash = true

      return @db
    end

    # Routen /
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
end
