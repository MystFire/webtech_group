class CreatePostingredients < ActiveRecord::Migration[5.0]
  def change
    create_table :postingredients do |t|
      t.integer :post_id
      t.integer :ingredient_id

      t.timestamps
    end
  end
end
