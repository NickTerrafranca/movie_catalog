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
  query = 'SELECT actors.name, actors.id FROM actors ORDER BY actors.name;'
  @actors = db_connection do |conn|
    conn.exec(query)
  end
  erb :'actors/index'
end

get '/actors/:id' do
  id = params[:id]
  query = "SELECT movies.title, cast_members.character, actors.name, actors.id
    FROM movies
    JOIN cast_members
    ON cast_members.movie_id = movies.id
    JOIN actors
    ON cast_members.actor_id = actors.id
    WHERE actors.id = #{id}
    ORDER BY movies.title;"
  @actor_movies = db_connection do |conn|
    conn.exec(query)
  end
erb :'actors/show'
end

get '/movies' do
  # id = params[:id]
  query = "SELECT movies.id, movies.title, movies.year, movies.rating, genres.name as genre, studios.name
  FROM movies
  JOIN genres
  ON movies.genre_id = genres.id
  JOIN studios
  ON movies.studio_id = studios.id
  ORDER BY movies.title
  LIMIT 20;"
  @movies = db_connection do |conn|
    conn.exec(query)
  end
  erb :'movies/index'
end
# Visiting /movies will show a table of movies, sorted alphabetically by title.
# The table includes the movie title, the year it was released, the rating, the genre,
#  and the studio that produced it. Each movie title is a link to the details page for that movie.


# get '/movies/:id' do
# end
