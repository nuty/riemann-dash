class Riemann::Dash::App

  enable :sessions

  get '/' do
    user = self.config.store.fetch(:username, nil)
    pass = self.config.store.fetch(:password, nil)
    if user.nil? or pass.nil?
      erb :index, :layout => false
    elsif session[:user].nil?
      redirect '/login', 302
    else
      erb :index, :layout => false
    end
  end

  post '/login' do
    username = request["username"]
    password = request["password"]
    user = authenticate(username, password)
    if user.nil?
      erb :login, :layout => false, :locals => { :text => "Wrong user/pass" }
    else
      redirect '/', 302
    end
  end

  get '/login' do
    user = self.config.store.fetch(:username, nil)
    pass = self.config.store.fetch(:password, nil)
    if user.nil? or pass.nil?
      redirect '/', 302
    elsif session[:user].nil?
      erb :login, :layout => false, :locals => { :text => "" }
    else
      redirect '/', 302
    end
  end

  get '/logout' do
    session[:user] = nil
    redirect '/login', 302
  end

  get '/config', :provides => 'json' do
    content_type "application/json"
    Riemann::Dash::BrowserConfig.read
  end

  post '/config' do
    # Read update
    request.body.rewind
    Riemann::Dash::BrowserConfig.update request.body.read
    content_type "application/json"
    Riemann::Dash::BrowserConfig.read
  end

  def authenticate(username, password)
    default_user = self.config.store.fetch(:username, nil)
    default_pass = self.config.store.fetch(:password, nil)
    if default_pass.nil? or default_user.nil?
      user = "none_user"
      redirect '/', 302
    elsif default_user == username and default_pass == password
      session[:user] = username
      user = username
    else
      user = nil
    end
    return user
  end

end
