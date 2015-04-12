class CreateArticles < ActiveRecord::Migration
  def change
    create_table :articles do |t|
      t.string :name
      t.string :ticker
      t.string :sentiment

      t.timestamps null: false
    end
  end
end
