require 'sinatra'
require 'sinatra/reloader'
require 'pry-byebug'
require 'rack-flash'
# createdb blogtastic => to create db
# Run the server (bundle exec rackup -p 4567)
# Open 'http://localhost:4567' in your browser

require_relative 'lib/blogtastic.rb'

class Blogtastic::Server < Sinatra::Application
  configure do
    set :bind, '0.0.0.0'
    enable :sessions
    use Rack::Flash
  end

  before do
    if session['user_id']
      user_id = session['user_id']
      db = Blogtastic.create_db_connection 'blogtastic'
      @current_user = Blogtastic::UsersRepo.find db, user_id
    else
      @current_user = {'username' => 'anonymous', 'id' => 5}
    end
  end


  ###################################################################
  # DO NOT EDIT ANYTHING ABOVE THIS AREA
  ###################################################################

  # Refer to `lib/blogtastic/repos/users_repo.rb` to see how you can
  # save and find users to handle the authentication process.

  get '/signup' do
    erb :'/auth/signup'
  end

  post '/signup' do
      db = Blogtastic.create_db_connection 'blogtastic'
      @user_name = params['user_name']
      @password1 = params['password1']
      @password2 = params['password2']
      
      if @password1 != @password2
        redirect to '/signup'
      else 
        @user_data = {:username => @user_name, :password => @password1} 
      end   
      @user = Blogtastic::UsersRepo.save(db, @user_data)
       session['user_id'] = @user['id']
       redirect to '/posts'
    # TODO: save user's info to db and create session
    # Create the session by adding a new key value pair to the
    # session hash. The key should be 'user_id' and the value
    # should be the user id of the user who was just created.
  end

  get '/signin' do
    erb :'auth/signin'
  end

  post '/signin' do
    db = Blogtastic.create_db_connection 'blogtastic'
    @user_name = params['user_name']
    @password = params['password']
    @user = Blogtastic::UsersRepo.find_by_name(db, @user_name)
    if @user && (@user['password'] == @password) 
      session['user_id'] =  @user['id'] 
      redirect to '/posts'
    elsif  @user && (@user['password'] != @password)
        redirect to '/signin'
    else   
       redirect to '/signup'
    end 
    # TODO: validate users credentials and create session
    # Create the session by adding a new key value pair to the
    # session hash. The key should be 'user_id' and the value
    # should be the user id of the user who just logged in.
  end

  get '/logout' do
    # TODO: destroy the session
    session.delete('user_id')
    redirect to '/'
  end

  get '/posts/:id/edit' do
    # TODO: destroy the session
    session
    redirect to '/posts/:id'
  end

  get '/comments/:id/edit' do
    db = Blogtastic.create_db_connection 'blogtastic'
    c = Blogtastic::CommentsRepo.find db, params[:id]
    @id = params[:id]
    @comment_user = Blogtastic::UsersRepo.find(db, c['user_id'])
    # binding.pry
    @post_id = c['post_id']
    if session['user_id'] == @comment_user['id']
      erb :'comments/edit'

    else 
    redirect to "/posts/#{@post_id}"
    end 
  end

  put '/comments/:id' do
    db = Blogtastic.create_db_connection 'blogtastic'
    comment_data = {'id' => params[:id], 'content' => params[:content]}
    c = Blogtastic::CommentsRepo.update(db, comment_data)
    redirect to "/posts/#{@post_id}"
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
      c['user'] = comment_user['username']
    end

    erb :'posts/post'
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
##########################################################

  delete '/comments/:id' do
    db = Blogtastic.create_db_connection 'blogtastic'
    Blogtastic::CommentsRepo.destroy db, params[:id]
    redirect to '/posts'
  end
end

