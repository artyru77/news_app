class NewsChannel < ApplicationCable::Channel
  def subscribed
    stream_from "news_channel"
  end
end
