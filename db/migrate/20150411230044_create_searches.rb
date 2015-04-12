class CreateSearches < ActiveRecord::Migration
  def change
    create_table :searches do |t|
      t.string :ticker
      t.string :name
      t.string :sentiment

      t.timestamps null: false
    end
  end
end
