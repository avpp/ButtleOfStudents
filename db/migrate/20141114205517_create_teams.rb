class CreateTeams < ActiveRecord::Migration
  def change
    create_table :teams do |t|
      t.string :name
      t.references :battle
      t.text :options
      t.timestamps
    end
  end
end
