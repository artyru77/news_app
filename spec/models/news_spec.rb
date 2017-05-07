require 'rails_helper'

RSpec.describe News::NewsBase, type: :model do
  subject(:news) { build :news }

  describe "validations" do
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:description) }
    it { is_expected.to be_valid }
  end

  describe "#to_hash" do
    let(:news_to_serialize) do
      build :news, title: "lorem", description: "ipsum", pub_date: Time.parse("2077-10-23 6:30:00")
    end

    let(:result_hash) do
      {
        title: "lorem",
        description: "ipsum",
        pub_date: I18n.l(Time.parse('2077-10-23 6:30:00').localtime, format: :long)
      }
    end

    it "returns correct json string" do
      expect(news_to_serialize.to_hash).to eq(result_hash)
    end
  end
end
