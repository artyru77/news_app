require 'rails_helper'

RSpec.describe News::CustomNews, type: :model do
  describe "validations" do
    it { should validate_presence_of(:expires_at) }
  end

  describe "callbacks" do
    let(:test_datetime) { "2077-10-23 6:30:00" }
    let(:news_to_save) { build :custom_news }

    describe "#before_save" do
      before do
        allow(Time.zone).to receive(:now).and_return(Time.parse(test_datetime))
        news_to_save.expires_at = test_datetime
        news_to_save.save
      end

      it "changes expires_at timezone from UTC to local" do
        expect(news_to_save.expires_at).to eq Time.parse("2077-10-23 6:30:00")
        expect(news_to_save.pub_date).to eq Time.parse(test_datetime)
      end
    end
  end
end
