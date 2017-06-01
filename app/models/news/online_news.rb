module News
  # Public: Online news class, that are fetched from web
  #
  class OnlineNews < News::NewsBase
    validates :expires_at, absence: true

    before_save do
      self.pub_date = Time.zone.now unless pub_date
    end
  end
end
