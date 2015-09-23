class AddBattleToTask < ActiveRecord::Migration
  def change
    add_reference :tasks, :battle, index: true
  end
end
