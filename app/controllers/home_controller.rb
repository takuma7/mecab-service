class HomeController < ApplicationController
  def index
    nm = Natto::MeCab.new
    if params.has_key?(:text) then
      @result = nm.parse(params[:text])
    else
      @result = ''
    end
  end
end
