FactoryGirl.define do
  factory :news, class: News::NewsBase do
    sequence(:title) { |n| "news_title_#{n}" }
    sequence(:description) { |n| "news_description_#{n}" }
  end

  factory :custom_news, parent: :news, class: News::CustomNews do
    expires_at Time.current
    sequence(:title) { |n| "custom_news_title_#{n}" }
    sequence(:description) { |n| "custom_news_description_#{n}" }
  end

  factory :online_news, parent: :news, class: News::OnlineNews do
    sequence(:title) { |n| "online_news_title_#{n}" }
    sequence(:description) { |n| "online_news_description_#{n}" }
  end
end
