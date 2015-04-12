class SearchesController < ApplicationController
  @search

  def index

  end

  def show
    charts
  end

  def new

  end

  def create
    #Indico.api_key = 'f921ed87f664b65b825d7fe1e86dfcab'
    @ticker = params[:q]
    stocks = StockQuote::Stock.quote(@ticker)
    @name = stocks.name

    start_date = Date.new(2015, 4, 6)
    end_date = Date.new(2015, 4, 11)
    stocks = StockQuote::Stock.history(stocks.symbol, start_date, end_date)
    @prices = []
    for stock in stocks
      @prices << stock.close
    end


    client = Twitter::REST::Client.new do |config|
      config.consumer_key        = "RRxDNNZ6uvYpn5YL7uP0CU6jV"
      config.consumer_secret     = "wzvfQr2DIiwr2aSSvlwLyaMe6RsOB1QXA0vhXhIfHYihN3nBr3"
      config.access_token        = "2888047671-yhl2xdeNEOZ1eUh1yqPwkZLc4eafNbmPkEIc12W"
      config.access_token_secret = "9aGcFm32wuyvVeZYTODrC5UWIV4J56eOssaul3qL8Ne1E"
    end

    @tweets_from_ticker = []
    @tweets_from_at_name = []
    @tweets_from_hashtag_name = []


    dates = ["06", "07", "08", "09", "10", "11"]

    for i in 0..4
      client.search("$#{@ticker}", result_type: "since:2015-04-#{dates[i]} until:2015-04-#{dates[i+1]}").take(10).collect do |tweet|
        @tweets_from_ticker << tweet.text
      end


      client.search("@#{@name}", result_type: "since:2015-04-#{dates[i]} until:2015-04-#{dates[i+1]}").take(10).collect do |tweet|
        @tweets_from_at_name << tweet.text
      end

      client.search("##{@name}", result_type: "since:2015-04-#{dates[i]} until:2015-04-#{dates[i+1]}").take(10).collect do |tweet|
        @tweets_from_hashtag_name << tweet.text
      end
    end

    dates_nums = [6, 7, 8, 9, 10, 11]

    @t1 = @tweets_from_at_name[0]
    @t2 = @tweets_from_at_name[1]
    @t3 = @tweets_from_at_name[2]
    @t4 = @tweets_from_at_name[3]
    @t5 = @tweets_from_at_name[4]
    @t6 = @tweets_from_at_name[5]
    @t7 = @tweets_from_at_name[6]
    @t8 = @tweets_from_at_name[7]
    @t9 = @tweets_from_at_name[8]
    @t10 = @tweets_from_at_name[9]



    @ticker_sentiment_arr = []
    @hashtag_sentiment_arr = []

    @temp_ticker = [0,0,0,0,0,0,0,0,0,0]
    @temp_hashtag = [0,0,0,0,0,0,0,0,0,0]

    for m in 0..5
      for i in m..(m+9)
        @temp_ticker[m] = Indico.sentiment(@tweets_from_ticker[i])
        @temp_hashtag[m] = Indico.sentiment(@tweets_from_hashtag_name[i])
      end
      @ticker_sentiment_arr << (@temp_ticker.sum.to_f / @temp_ticker.size) * 100
      @hashtag_sentiment_arr << (@temp_hashtag.sum.to_f / @temp_hashtag.size) * 100
    end


    #@ticker, @name

    #render text: "#{@ticker_sentiment_score} and #{@price}"

    related = []
    industry = JSON.parse(Indico.text_tags(@name).to_json)
    industry.each do |topic, score|
      if score > 0.03
        related << topic
      end
    end

    @related_hash = Hash.new
    related.each do |topic|
      @related_hash[topic] = Indico.sentiment(topic) * 100
    end

    @related_topics = []
    @related_sentiments = []
    @related.hash do |topic, sentiment|
      @related_topics << topic
      @related_sentiments << sentiment
    end

    @topic1 = related[0]
    @topic2 = related[1]
    @topic3 = related[2]
    @topic4 = related[3]

    @score1 = (Indico.sentiment(related[0]) * 100) - 50
    @score2 = (Indico.sentiment(related[1]) * 100) - 50
    @score3 = (Indico.sentiment(related[2]) * 100) - 50
    @score4 = (Indico.sentiment(related[3]) * 100) - 50


    @ticker_hist = [0,0,0,0,0]
    @hashtag_hist = [0,0,0,0,0]

    for i in 0..4
        j = (@hashtag_sentiment_arr[i]/10).to_i;
        @hashtag_hist[j] = @hashtag_hist[j].to_i + 1;
        j = (@ticker_sentiment_arr[i]/10).to_i;
        @ticker_hist[j] = @ticker_hist[j].to_i + 1;
    end
    #render text: "#{@related_hash}"

    #render text: "#{@ticker} \n #{@ticker_sentiment} \n #{@at_sentiment} \n #{@hashtag_sentiment} \n #{@prices}"
    # related_hash stores related keywords and their sentiments
    # TYPE_sentiment should be of lenght five and has sentiments for past five days
    # prices should be of length five and has prices for past five days

    # @ticker_sentiment_arr SIZE 5
    # @at_sentiment_arr
    # @hashtag_sentiment_arr

    # @prices SIZE 5


    @days = [0,1,2,3,4]






    charts
  end

  def update
  end

  def destroy

  end

  def search

  end



  def charts


    @chart = LazyHighCharts::HighChart.new('graph') do |f|
     # var ticker = @ticker_sentiment_score
      f.title(:text => "Sentiment Distrubtion")
      f.xAxis(:categories => ["0-10", "11-20", "21-30", "31-40", "41-50", "51-60","61-70","71-80","81-90","91-100"])
      f.series(:name => "Analysts", :yAxis => 0, :data => @ticker_hist)
      f.series(:name => "Company", :yAxis => 0, :data => @hashtag_hist)

    #  f.series(:name => "Population in Millions", :yAxis => 1, :data => [1, 127, 1340, 81, 65])

      f.yAxis [
        {:title => {:text => "Responses", :margin => 70} },
                {:title => {:text => ""}},
        {:title => {:text => ""}, :opposite => true},
      ]

    f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)
    f.chart({:defaultSeriesType=>"column"})
    end



    @chart2 = LazyHighCharts::HighChart.new('graph') do |f|
     # var ticker = @ticker_sentiment_score
      f.title(:text => "Past Five Days")
    #  f.xAxis(:categories => ["0-10", "11-20", "21-30", "31-40", "41-50", "51-60","61-70","71-80","81-90","91-100"])
    #  f.series(:name => "Days", :xAxis => 0, :data => @days)
      f.series(:name => "Daily Sentiment", :xAxis => 0, :data => @ticker_sentiment_arr)
      f.series(:name => "Daily Price", :yAxis => 0, :data => @prices)
     # f.series(:name => "Analysts", :yAxis => 1, :data => @ticker_sentiment_arr)
    #  f.series(:name => "Consumers", :yAxis => 2, :data => @hashtag_sentiment_arr)
   #   f.series(:name => "Companies", :yAxis => 3, :data => @at_sentiment_arr)
      #f.chart({:defaultSeriesType=>"line" })
      f.chart({:defaultSeriesType=>"line" })
    #  f.series(:name => "Population in Millions", :yAxis => 1, :data => [1, 127, 1340, 81, 65])

      f.yAxis [
        {:title => {:text => "Responses", :margin => 70} },
        {:title => {:text => "Sentiment Value"}, :opposite => true},
        {:title => {:text => ""}, :opposite => true},
      ]
      f.xAxis(:title => { :text => "Day"} )

    f.legend(:align => 'right', :verticalAlign => 'top', :y => 75, :x => -50, :layout => 'vertical',)


   # f.plotOptions({}) # override the default values that lazy_high_charts puts there
   # f.legend({}) # override the default values

    end




    render "create.html" , search: "create"
  end

end
