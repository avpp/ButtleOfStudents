class AddOwnerToBattle < ActiveRecord::Migration
  def change
    add_reference :battles, :user, index: true
  end
end
