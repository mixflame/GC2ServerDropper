class MainController < ApplicationController
  def welcome
    @greeting = "Welcome to GlobalChat2!<br>"*68
  end
end
