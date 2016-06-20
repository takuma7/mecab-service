require 'uri'

class HomeController < ApplicationController
  def index
    nm = Natto::MeCab.new
    @words_list = []
    @message = ''
    if params.has_key?(:twitter_id) then
      # @result = nm.parse(params[:text])
      begin
        @tweets = $twitter.user_timeline(params[:twitter_id],
            {count: 200, include_rts: false}
          ).map{|t| t.text}
      rescue Exception => e
        @tweets = []
        @message = "Invalid User Name"
        return
      end
      @parsed_tweets = @tweets.map{|t|
        _t = t.gsub(/@[A-Za-z0-9_]+/, '')
              .gsub(URI.regexp, '')
              .gsub(/RT:?/, '')
        a=[]
        nm.parse(_t) do |n|
          features = n.feature.split(',')
          next if(features[0]!="名詞")
          next if(!features[1].in?(%w(サ変接続 一般 形容動詞語幹 固有名詞)))
          a.push(n.surface)
        end
        a
      }.flatten
      @result = @parsed_tweets
      @words_list_tmp = @parsed_tweets.inject(Hash.new(0)){|h,i| h[i] += 1; h}
      @minCount = 99999
      @maxCount = 0
      @words_list_tmp.each do |w,c|
        @minCount = c if @minCount > c
        @maxCount = c if @maxCount < c
      end
      @maxSize = 100
      @minSize = 10
      def scaleSize(x)
        return @minSize if (@maxCount - @minCount)==0
        @minSize + (x-@minCount)/(@maxCount-@minCount)*(@maxSize-@minSize)
      end
      @words_list = @words_list_tmp.inject({}){|a,(k,v)| a[k]=scaleSize(v);a}
    else
      @result = ''
    end
  end
end
