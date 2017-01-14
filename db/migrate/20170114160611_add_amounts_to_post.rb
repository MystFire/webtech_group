class AddAmountsToPost < ActiveRecord::Migration[5.0]
  def change
    add_column :posts, :amount, :integer
  end
end
