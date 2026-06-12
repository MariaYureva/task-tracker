class CreateTaskExceptions < ActiveRecord::Migration[7.1]
  def change
    create_table :task_exceptions do |t|
      t.references :task, null: false, foreign_key: true
      t.date    :original_date, null: false
      t.date    :scheduled_date, null: true
      t.string  :status, null: true
      t.string  :title, null: true
      t.text    :description, null: true

      t.timestamps
    end

    add_index :task_exceptions, %i[task_id original_date], unique: true
  end
end