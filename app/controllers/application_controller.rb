class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  before_action :say_hello!

  def say_hello!
    puts "hello!"
  end
end
