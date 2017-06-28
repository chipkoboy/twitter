require 'sinatra'
require 'data_mapper'
DataMapper.setup(:default, 'sqlite:///'+Dir.pwd+'/project.db')
set :bind, '0.0.0.0'

class User
	include DataMapper::Resource

	property :id, Serial
	property :username, String
	property :email, String
	property :password, String
    property :done,Boolean

 end

class Tweet
		include DataMapper::Resource

         property :id,          Serial
         property :message,     String
         property :user_id,     Numeric



	def like_count
		Likes.all(tweet_id: id).length
	end

	def liked_by user_id
		Likes.all(tweet_id: id, user_id: user_id).length > 0
	end
 end

class Likes
	    include DataMapper::Resource	
	    property :id,          Serial
	    property :user_id,     Numeric
	    property :tweet_id,    Numeric 
 end	    

class Follow
	include DataMapper::Resource
	property :id,            Serial
	property :user_id,       Numeric
	property :follower_id,   Numeric
	property :following_id,  Numeric
end

DataMapper.finalize
DataMapper.auto_upgrade!

enable :sessions


get '/' do
	if session[:user_id].nil?
		return redirect '/signin'
	else
     tweets=Tweet.all
     likes=Likes.all
     #likes=Likes.all()
     erb :Index, locals: {user_id: session[:user_id], tweets: tweets, likes: likes}
     
end


end
get '/signout' do
	session[:user_id] = nil

	return redirect '/'
end



get '/signin' do
	erb :signin
end

post '/signin' do
	email = params["email"]
	password = params["password"]
	user = User.all(email: email).first
	if user.nil?
		        return redirect '/signup'
    	elsif  
    		    password ==''
			    return redirect '/signin'
		elsif 
			    user.password == password
    			session[:user_id] = user.id
    			return redirect '/'
    	else
    			return redirect '/signin'
    	end

	end 



get '/signup' do
	erb :signup
end

post '/signup' do
	username = params["username"]
	email = params["email"]
	password = params["password"]

	user = User.all(email: email).first

	if user
		return redirect '/signin'
	else
		user = User.new
		user.email = email
		user.password = password
		user.username = username
		user.done = false

		if password ==''
			return redirect '/signup'
		else

		user.save
		session[:user_id] = user.id
		return redirect '/'
	end
end

end


post '/like' do
	tweet_id = params[:tweet_id].to_i
	puts tweet_id
	like = Likes.all(tweet_id: tweet_id, user_id: session[:user_id].to_i).first
	unless like
		like = Likes.new
		like.tweet_id = tweet_id
		like.user_id = session[:user_id]
		like.save
	else
		like.destroy
	end

	return redirect '/'

end


post '/add_Tweet' do

         tweet=Tweet.new
         user=User.new
         message=params["message"]
         tweet.message=message
         tweet.user_id=session[:user_id]
         tweet.save
         return redirect '/'

end


post '/del' do

id=params[:id].to_i
tweet=Tweet.get(id)
tweet.destroy
return redirect '/'
end


get '/likers' do
	likes=Likes.all
    tweets=Tweet.all
		erb :likers, locals: {user_id: session[:user_id], tweets: tweets, likes: likes}
end

get '/total_users' do
    users=User.all
    follow=Follow.all
	erb :total_users, locals: {users: users,follow: follow}
end

post '/done' do
	user_id=params[:user_id].to_i
	User.each do |user|

		if user.id==user_id
			user.done = !user.done

		end
    end
    return redirect '/done'
end

post '/back' do
	return redirect '/'
end

