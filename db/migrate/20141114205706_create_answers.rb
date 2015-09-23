class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.text :options
      t.references :user
      t.references :task
      t.timestamps
    end
  end
end
