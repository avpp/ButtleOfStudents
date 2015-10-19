class AddOnlyMyToBattle < ActiveRecord::Migration
  def change
    add_column :battles, :only_my_student, :boolean, :default=>false
  end
end
