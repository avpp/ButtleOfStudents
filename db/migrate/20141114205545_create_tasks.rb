class CreateTasks < ActiveRecord::Migration
  def change
    create_table :tasks do |t|
      t.references :task_type
      t.references :team
      t.references :user
      t.text :options

      t.timestamps
    end
  end
end
