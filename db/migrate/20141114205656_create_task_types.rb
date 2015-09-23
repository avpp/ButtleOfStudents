class CreateTaskTypes < ActiveRecord::Migration
  def change
    create_table :task_types do |t|
      t.text :options
      t.timestamps
    end
  end
end
