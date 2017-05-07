require 'rails_helper'

RSpec.describe NewsHandler do
  let(:feed_mock) do
    RSS::Maker.make("2.0") do |maker|
      maker.channel.link = "http://www.ruby-lang.org/en/feeds/news.rss"
      maker.channel.title = "Example feed"
      maker.channel.description = "Example feed"
      maker.items.new_item do |item|
        item.description = "rss feed"
        item.title = "rss feed"
        item.pubDate = Time.current.yesterday.to_s
      end
    end
  end

  before do
    allow(RSS::Parser).to receive(:parse).with(anything).and_return(feed_mock)
    described_class.instance_variable_set(:@current_news, nil)
    described_class.instance_variable_set(:@need_broadcast, nil)
  end

  describe "#sync_current_news_with_yandex" do
    context "when @current_news is nil and there is news in db" do
      let!(:stored_news) { create :online_news, pub_date: feed_mock.items.first.pubDate }

      before do
        described_class.instance_variable_set(:@need_broadcast, false)
        described_class.instance_variable_set(:@current_news, nil)
      end

      it "updates @current_news with stored news and sets need_broadcast flag to true" do
        expect { described_class.update_news }.to not_change { News::OnlineNews.count }
          .and change { described_class.instance_variable_get(:@need_broadcast) }

        expect(described_class.current_news.title).to eq stored_news.title
      end
    end

    context "when @current_news is old and it is need to be refreshed" do
      before do
        described_class.instance_variable_set(:@need_broadcast, false)
        described_class.instance_variable_set(:@current_news, build(:online_news, pub_date: Time.current - 10.days))
      end

      it "updates @current_news with rss feed and sets need_broadcast flag to true" do
        expect { described_class.update_news }.to change { News::OnlineNews.count }.by(1)
          .and change { described_class.instance_variable_get(:@need_broadcast) }

        expect(described_class.current_news.title).to eq feed_mock.items.first.title
      end
    end

    context "when @current_news is same as received rss feed" do
      before do
        described_class.instance_variable_set(
          :@current_news, create(:online_news, pub_date: feed_mock.items.first.pubDate)
        )
        described_class.instance_variable_set(:@need_broadcast, true)
      end

      it "does not update current_news and sets need_broadcast flag to false" do
        expect { described_class.update_news }.to not_change { News::OnlineNews.count }
          .and change { described_class.instance_variable_get(:@need_broadcast) }
      end
    end
  end

  describe "#update_news" do
    context "when custom news is expired" do
      context "when rss feed is fresh" do
        before do
          described_class.instance_variable_set(:@need_broadcast, false)
          described_class.instance_variable_set(
            :@current_news, create(:custom_news, expires_at: Time.current.yesterday)
          )
        end

        it "updates @current_news with rss feed" do
          expect { described_class.update_news }.to change { News::OnlineNews.count }.by(1)
            .and change { described_class.instance_variable_get(:@need_broadcast) }

          expect(described_class.current_news.title).to eq feed_mock.items.first.title
        end
      end

      context "when rss feed is same as stored in db" do
        before do
          described_class.instance_variable_set(:@need_broadcast, false)
          described_class.instance_variable_set(
            :@current_news, create(:custom_news, expires_at: Time.current.yesterday)
          )
          create :online_news, pub_date: feed_mock.items.first.pubDate.utc,
                               title: feed_mock.items.first.title,
                               description: feed_mock.items.first.description
        end

        it "updates @current_news with rss feed" do
          expect { described_class.update_news }.to not_change { News::OnlineNews.count }
            .and change { described_class.instance_variable_get(:@need_broadcast) }

          expect(described_class.current_news.title).to eq feed_mock.items.first.title
        end
      end
    end

    context "when custom news is not expired" do
      let(:custom_news) { create :custom_news, expires_at: Time.current.tomorrow }

      context "when @current_news is same as custom news" do
        before do
          described_class.instance_variable_set(:@current_news, custom_news)
          described_class.instance_variable_set(:@need_broadcast, true)
        end

        it "does not update @current_news and sets need_broadcast flag to false" do
          expect { described_class.update_news }.to not_change { described_class.current_news.title }
            .and change { described_class.instance_variable_get(:@need_broadcast) }
        end
      end

      context "when @current_news is not same as custom news" do
        before do
          described_class.instance_variable_set(:@current_news, custom_news.dup)
          custom_news.update_columns(title: "new title", pub_date: custom_news.pub_date + 1.day)
          described_class.instance_variable_set(:@need_broadcast, false)
        end

        it "updates @current_news and sets need_broadcast flag to false" do
          expect { described_class.update_news }.to change { described_class.current_news.title }
            .and change { described_class.instance_variable_get(:@need_broadcast) }
        end
      end
    end
  end
end
