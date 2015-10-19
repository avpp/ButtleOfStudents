class AddChefToUser < ActiveRecord::Migration
  def change
    add_reference :users, :chef, references: :users
  end
end
