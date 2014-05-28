require 'sinatra'
require 'pg'
require 'pry'

def db_connection
  begin
    connection = PG.connect(dbname: 'movies')

    yield(connection)

  ensure
    connection.close
  end
end

get '/actors' do
  @actors = db_connection do |conn|
    conn.exec('SELECT actors.name, actors.id FROM actors ORDER BY actors.name;')
  end
  erb :'actors/index'
end

get '/actors/:id' do
  id = params[:id]
  query = "SELECT movie.name, cast_members.character, actors.name, actors.id
      JOIN cast_members ON cast_members.movie_id = movies.id
      JOIN actors ON actors.id = cast_members.actor_id WHERE actors.id = #{id}
      ORDER BY movies.name;"
  @actor_movies = db_connection do |conn|
    conn.exec(query)
  end
erb :'actors/show'
end

# get '/movies' do
# end

# get '/movies/:id' do
# end
