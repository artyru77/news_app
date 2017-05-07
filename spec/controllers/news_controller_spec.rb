require 'rails_helper'

RSpec.describe NewsController do
  render_views

  before do
    allow(NewsHandler).to receive(:fetch_yandex_news)
    allow(ActionCable.server).to receive(:broadcast).with(anything, anything)
  end

  RSpec.shared_examples "calls update_and_broadcast if save was succesfull" do |verb, action|
    let(:params) do
      {
        id: create(:custom_news).id,
        news_custom_news: {
          expires_at: Time.current,
          title: "test",
          description: "test"
        }
      }
    end
    it do
      expect(NewsHandler).to receive(:update_and_broadcast_if_needed)
      allow(controller).to receive(:render)
      send(verb, action, params: params)
    end
  end

  describe "#show" do
    it "calls update_and_broadcast, current_news" do
      expect(NewsHandler).to receive(:update_and_broadcast_if_needed)
      expect(NewsHandler).to receive(:current_news)
      allow(controller).to receive(:render)
      get :show
    end
  end

  describe "#admin" do
    it "calls update_and_broadcast, current_news" do
      expect(NewsHandler).to receive(:update_news)
      expect(NewsHandler).to receive(:current_news)
      allow(controller).to receive(:render)
      get :admin
    end
  end

  describe "#create" do
    include_examples "calls update_and_broadcast if save was succesfull", :post, :create
  end

  describe "#update" do
    include_examples "calls update_and_broadcast if save was succesfull", :patch, :update
  end

  describe "#edit" do
    context "when current_news contains actual custom news" do
      let!(:news) { create :custom_news, expires_at: Time.zone.now.tomorrow }

      it "returns form with custom news data" do
        get :admin
        expect(response.body).to have_field("news_custom_news[title]", exact: news.title)
      end
    end

    context "when current_news contains expired custom news" do
      let!(:news) { create :custom_news, expires_at: Time.zone.now.yesterday }

      it "returns form with custom news data" do
        get :admin
        expect(response.body).to have_field("news_custom_news[title]", exact: "")
      end
    end
  end
end
