module News
  # Public: Custom news class, that can be created from /admin page
  #
  class CustomNews < News::NewsBase
    validates :expires_at, presence: true

    before_save do
      # rails strong parameters gem converts datetime string into Time with UTC +000 timezone
      # so we need to convert that string into local time
      self.expires_at = expires_at.to_s(:db).to_time

      self.pub_date = Time.zone.now
    end

    # Public: Check if CustomNews is expired
    #
    # Examples
    #
    #   News::CustomNews.create(title: "lorem", description: "ipsum", expires_at: Time.current.yesterday).expired?
    #   # => true
    #
    # Returns bool.
    def expired?
      expires_at <= Time.zone.now
    end
  end
end
