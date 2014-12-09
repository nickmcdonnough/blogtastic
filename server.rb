require 'sinatra'
require 'sinatra/reloader'
require 'pry-byebug'
require 'rack-flash'

require_relative 'lib/blogtastic.rb'

class Blogtastic::Server < Sinatra::Application
  configure do
    enable :sessions
    use Rack::Flash
  end

  before do
    if session['user_name']
      user_id = session['user_id']
      db = Blogtastic.create_db_connection 'blogtastic'
      @current_user = Blogtastic::UsersRepo.find db, user_id
    else
      @current_user = {'name' => 'anonymous', 'id' => 1}
    end
  end



  ###################################################################
  # DO NOT EDIT ANYTHING ABOVE THIS AREA
  ###################################################################

  get '/signup' do
    # TODO: render template with form for user to sign up
  end

  post '/signup' do
    # TODO: save user's info to db and create session
  end

  get '/signin' do
    # TODO: render template for user to sign in
  end

  post '/signin' do
    # TODO: validate users credentials and create session
  end

  get '/logout' do
    # TODO: destroy the session
  end

  ###################################################################
  # DO NOT EDIT ANYTHING BELOW THIS AREA
  ###################################################################



  # landing
  get '/' do
    erb :index
  end

  # view all posts
  get '/posts' do
    db = Blogtastic.create_db_connection 'blogtastic'
    @posts = Blogtastic::PostsRepo.all db
    erb :'posts/index'
  end

  # new post page
  get '/posts/new' do
    erb :'posts/new'
  end

  # create a new post
  post '/posts' do
    post = {
      title:   params[:title],
      content: params[:content],
      user_id:    params[:user_id]
    }
    db = Blogtastic.create_db_connection 'blogtastic'
    Blogtastic::PostsRepo.save db, post

    redirect to '/posts'
  end

  # view a particular post
  get '/posts/:id' do
    db = Blogtastic.create_db_connection 'blogtastic'
    @post = Blogtastic::PostsRepo.find db, params[:id]
    @comments = Blogtastic::CommentsRepo.post_comments db, params[:id]
    @user = Blogtastic::UsersRepo.find db, @post['user_id']

    @comments.map do |c|
      comment_user = Blogtastic::UsersRepo.find db, c['user_id']
      c['user'] = comment_user['name']
    end

    erb :'posts/post'
  end

  # new comment page 
  get '/posts/:post_id/comments/new' do
    erb :'comments/new'
  end

  # create a new comment on a post
  post '/posts/:post_id/comments' do
    comment = {
      content: params[:content],
      user_id: params[:user_id],
      post_id: params[:post_id]
    }
    db = Blogtastic.create_db_connection 'blogtastic'
    Blogtastic::CommentsRepo.save db, comment
    redirect to '/posts/' + params[:post_id]
  end

  # delete a post
  delete '/posts/:id' do
    db = Blogtastic.create_db_connection 'blogtastic'
    Blogtastic::PostsRepo.destroy db, params[:id]
    redirect to '/posts'
  end

  # delete a comment
  delete '/posts/:post_id/comments/:id' do
    redirect to '/posts' + params[:post_id]
  end
end
