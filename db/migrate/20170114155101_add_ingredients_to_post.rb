class AddIngredientsToPost < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :ingredients, :string
  end
end
