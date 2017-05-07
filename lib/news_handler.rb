require 'rss'
require 'open-uri'

# Public: Handler for actualization and synchronization news, that would be used for displaying,
# with user-created news or online news.
#
class NewsHandler
  class << self

    # Public: Get current news, that are showed to users in their browsers
    #
    # Examples
    #
    #   NewsHandler.current_news
    #   # => #<News::CustomNews id: 24, title: "My first created news!", description: "ipsum", type: "News::CustomNews",
    #        expires_at: "2077-10-23 18:51:00", pub_date: "2077-10-23 18:49:34", created_at: "2077-10-23 18:49:34",
    #        updated_at: "2017-05-07 18:49:34">
    #
    # Returns News::CustomNews or News::OnlineNews
    def current_news
      @current_news
    end

    # Public: Actualize current news, with data from database(if actual news is custom created news) or
    # with data from web(if current news was expired or nil)
    #
    # Examples
    #
    #   NewsHandler.current_news
    #   # => nil
    #   NewsHandler.update_news
    #   # => nil
    #   NewsHandler.current_news
    #   # => #<News::CustomNews id: 24, title: "My first created news!", description: "ipsum", type: "News::CustomNews",
    #        expires_at: "2077-10-23 18:51:00", pub_date: "2077-10-23 18:49:34", created_at: "2077-10-23 18:49:34",
    #        updated_at: "2017-05-07 18:49:34">
    #
    # Returns nothing
    def update_news
      last_custom_news = News::CustomNews.last

      if last_custom_news.nil? || last_custom_news.expired?
        sync_current_news_with_yandex
      else
        @need_broadcast = (@current_news.nil? || @current_news.pub_date < last_custom_news.pub_date)
        @current_news = last_custom_news
      end
    end

    # Public: Update current_news and broadcast it to users if needed via ActionCable server.
    # If updated news is equal with actuaized news, then broadcast will be not performed
    #
    # Examples
    #
    #   NewsHandler.update_and_broadcast_if_needed
    #   # => nil
    #
    # Returns nothing
    def update_and_broadcast_if_needed
      update_news
      begin
        ActionCable.server.broadcast("news_channel", news: @current_news.to_hash) if @need_broadcast
      rescue Redis::CannotConnectError
      end
    end

    private

    # Private: Receive last rss item from yandex rss
    #
    # Examples
    #
    #   feed_item = fetch_yandex_news
    #   # => #<RSS::Rss::Channel::Item:0x00000003b44b98 @parent=nil ......
    #
    # Returns RSS::Rss::Channel::Item
    def fetch_yandex_news
      feed = RSS::Parser.parse(Rails.configuration.news['yandex_news_rss_url'])
      return unless feed&.items && !feed.items.size.zero?

      feed.items.sort_by(&:pubDate).reverse.first
    end

    # Private: Synchronize current_news with yandex feed item. If current news is expired, then News::OnlineNews will be
    # created. If current_news is same as received feed item, then it does not change its value
    #
    # Examples
    #
    #   sync_current_news_with_yandex
    #   # => nil
    #   NewsHandler.current_news
    #   # => #<News::CustomNews id: 25, title: "Updated news from web", description: "ipsum", type: "News::OnlineNews",
    #        expires_at: "2077-10-23 18:51:00", pub_date: "2077-10-23 18:49:34", created_at: "2077-10-23 18:49:34",
    #        updated_at: "2017-05-07 18:49:34">
    #
    # Returns nothing
    def sync_current_news_with_yandex
      feed_item = fetch_yandex_news
      return if feed_item.nil?

      last_online_news = News::OnlineNews.last
      if @need_broadcast = (last_online_news.nil? || (last_online_news.pub_date < feed_item.pubDate.utc))
        @current_news = News::OnlineNews.create!(
          pub_date: feed_item.pubDate.utc,
          title: feed_item.title,
          description: feed_item.description
        )
      elsif @need_broadcast = (@current_news.nil? || @current_news.is_a?(News::CustomNews))
        @current_news = last_online_news
      end
    end
  end
end
