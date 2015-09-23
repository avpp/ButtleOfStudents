class CreateBattles < ActiveRecord::Migration
  def change
    create_table :battles do |t|
      t.text :options
      t.timestamp :start_time
      t.timestamp :end_time
      t.timestamps
    end
  end
end
