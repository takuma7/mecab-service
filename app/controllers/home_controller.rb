class HomeController < ApplicationController
  def index
    nm = Natto::MeCab.new
    @result = nm.parse(params[:text])
  end
end
