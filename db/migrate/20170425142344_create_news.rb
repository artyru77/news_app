class CreateNews < ActiveRecord::Migration[5.0]
  def change
    create_table :news do |t|
      t.string :title
      t.text :description
      t.string :type
      t.datetime :expires_at
      t.datetime :pub_date

      t.timestamps
    end
  end
end
