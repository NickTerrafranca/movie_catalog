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
  query = 'SELECT actors.name, actors.id
  FROM actors
  ORDER BY actors.name
  LIMIT 100;'
  @actors = db_connection do |conn|
    conn.exec(query)
  end
  erb :'actors/index'
end

get '/movies' do
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

get '/actors/:id' do
  id = params[:id]
  query = "SELECT movies.title, cast_members.character, actors.name, actors.id
    FROM movies
    JOIN cast_members
    ON cast_members.movie_id = movies.id
    JOIN actors
    ON cast_members.actor_id = actors.id
    WHERE actors.id = $1
    ORDER BY movies.title;"
  @actor_movies = db_connection do |conn|
    conn.exec_params(query, [id])
  end
  erb :'actors/show'
end

get '/movies/:id' do
  id = params[:id]
  query = "SELECT movies.title, movies.year, movies.synopsis, movies.rating, genres.name AS genre_name,
  studios.name AS studio_name, actors.id, actors.name AS actor_name, cast_members.character
    FROM movies
    JOIN genres
    ON movies.genre_id = genres.id
    JOIN studios
    ON movies.studio_id = studios.id
    JOIN cast_members
    ON cast_members.movie_id = movies.id
    JOIN actors
    ON cast_members.actor_id = actors.id
    WHERE movies.id = $1;"
  @movie_details = db_connection do |conn|
    conn.exec(query, [id])
  end
  erb :'movies/show'
end


# Visiting /movies/:id will show the details for the movie.
# This page should contain information about the movie (including genre and studio)
# as well as a list of all of the actors and their roles. Each actor name is a link to the
# details page for that actor.

# actors.name AS actor_name


#{id}
