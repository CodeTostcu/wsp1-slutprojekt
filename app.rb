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

end
