class NewsController < ApplicationController
  def show
    NewsHandler.update_and_broadcast_if_needed
    @current_news = NewsHandler.current_news
  end

  def admin
    NewsHandler.update_news
    @custom_news = NewsHandler.current_news.is_a?(News::CustomNews) ? NewsHandler.current_news : News::CustomNews.new
    render :admin
  end

  def create
    @custom_news = News::CustomNews.new news_params
    if @custom_news.save
      NewsHandler.update_and_broadcast_if_needed
      redirect_to root_path
    else
      render :admin
    end
  end

  def update
    @custom_news = News::CustomNews.find params[:id]
    if @custom_news.update news_params
      NewsHandler.update_and_broadcast_if_needed
      redirect_to root_path
    else
      render :admin
    end
  end

  private

  def news_params
    params.require(:news_custom_news).permit(:expires_at, :title, :description)
  end
end
