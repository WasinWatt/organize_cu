class SessionsController < ApplicationController
  def new
    render layout: "layouts/free"
  end

  def create
    personnel = Personnel.find_by(email: params[:session][:email].downcase)
    
    if personnel && personnel.authenticate(params[:session][:password])
      log_in personnel
      redirect_back_or personnel
    else
      flash.now[:danger] = "Invalid email/password"
      render 'new', layout: "layouts/free"
    end
    
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
end
