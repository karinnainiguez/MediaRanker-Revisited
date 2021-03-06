class SessionsController < ApplicationController
  def login_form
  end

  def login
    auth_hash = request.env['omniauth.auth']

    if auth_hash[:uid]
      # if github sent us the right data
      user = User.find_by(uid: auth_hash[:uid], provider: auth_hash[:provider])
      if user.nil?
        # new user
        user = User.new(
          username: auth_hash[:info][:name],
          email: auth_hash[:info][:email],
          provider: auth_hash[:provider],
          uid: auth_hash[:uid]
        )
        if user.save
          # new user created successfully
          session[:user_id] = user.id
          flash[:status] = :success
          flash[:result_text] = "Successfully added new user #{user.username}"
        else
          # new user could not be created
          flash[:status] = :failure
          flash[:result_text] = "Sorry, new user could not be created"
        end

      else
        # user found in database
        session[:user_id] = user.id
        flash[:status] = :success
        flash[:result_text] = "Successfully logged in #{user.username}"
      end

    else
      # if insufficient data from provider
      flash[:status] = :failure
      flash[:result_text] = "Sorry, login failed"
    end
    redirect_to root_path
  end
  #
  # def login
  #   username = params[:username]
  #   if username and user = User.find_by(username: username)
  #     session[:user_id] = user.id
  #     flash[:status] = :success
  #     flash[:result_text] = "Successfully logged in as existing user #{user.username}"
  #   else
  #     user = User.new(username: username)
  #     if user.save
  #       session[:user_id] = user.id
  #       flash[:status] = :success
  #       flash[:result_text] = "Successfully created new user #{user.username} with ID #{user.id}"
  #     else
  #       flash.now[:status] = :failure
  #       flash.now[:result_text] = "Could not log in"
  #       flash.now[:messages] = user.errors.messages
  #       render "login_form", status: :bad_request
  #       return
  #     end
  #   end
  #   redirect_to root_path
  # end

  def logout
    session[:user_id] = nil
    flash[:status] = :success
    flash[:result_text] = "Successfully logged out"
    redirect_to root_path
  end
end
