module News
  # Public: Base class for news models
  #
  # Examples
  #
  #   class SomeNews < News::NewsBase
  #   end
  #
  class NewsBase < ApplicationRecord
    self.table_name = 'news'
    validates :title, :description, presence: true

    # Public: Prepare model for transmitting via ActionCable.
    #
    # Examples
    #
    #   News::CustomNews.create(title: "lorem", description: "ipsum", pub_date: Time.current).to_hash
    #   # => {:title=>"lorem", :description=>"ipsum", :pub_date=>"22:05 07-May-2017"}
    #
    # Returns hash.
    def to_hash
      {
        title: self.title,
        description: self.description,
        pub_date: I18n.l(self.pub_date.localtime, format: :long),
      }
    end
  end
end
