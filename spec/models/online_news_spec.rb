require 'rails_helper'

RSpec.describe News::OnlineNews, type: :model do
  describe "validations" do
    it { should validate_absence_of(:expires_at) }
  end

  describe "callbacks" do
    describe "#before_save" do
      let(:test_datetime) { Time.parse("2077-10-23 6:30:00") }

      context "when pub_date is not provided" do
        let(:news_to_save) { build :online_news }

        before do
          allow(Time).to receive(:now).and_return(test_datetime)
          news_to_save.save!
        end

        it "saves with current time" do
          expect(news_to_save.pub_date).to eq(test_datetime)
        end
      end

      context "when pub_date is provided" do
        let(:news_to_save) { build :online_news, pub_date: test_datetime - 1.day }

        before { news_to_save.save! }

        it "saves with provided time" do
          expect(news_to_save.pub_date).to eq(test_datetime - 1.day)
        end
      end
    end
  end
end
