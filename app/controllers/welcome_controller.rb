class WelcomeController < ApplicationController

  access_control do
    allow all
  end

  def index
    if user_signed_in?
      redirect_to user_path(current_user)
    end
  end
end
