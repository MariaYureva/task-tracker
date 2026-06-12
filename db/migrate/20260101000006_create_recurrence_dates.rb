class CreateRecurrenceDates < ActiveRecord::Migration[7.1]
  def change
    create_table :recurrence_dates do |t|
      t.references :task, null: false, foreign_key: true
      t.date :date, null: false

      t.timestamps
    end

    add_index :recurrence_dates, %i[task_id date], unique: true
  end
end