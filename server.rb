require "sinatra"
require "pg"
require_relative "./app/models/article"

set :views, File.join(File.dirname(__FILE__), "app/views")

configure :development do
  set :db_config, { dbname: "news_aggregator_development" }
end

configure :test do
  set :db_config, { dbname: "news_aggregator_test" }
end

def db_connection
  begin
    connection = PG.connect(Sinatra::Application.db_config)
    yield(connection)
  ensure
    connection.close
  end
end

get '/articles' do

  db_connection do |conn|
    @articles = conn.exec("SELECT title, url, description FROM articles")
  end


  erb :index
end

post '/articles' do

  title = params['article_title']
  url = params['url']
  description = params['description']

  db_connection do |conn|
    conn.exec_params("INSERT INTO articles (title, description, url)
      VALUES ($1, $2, $3);",
      ["#{title}", "#{description}", "#{url}"])
  end

  redirect '/articles'
end

get '/articles/new' do
  erb :new
end
