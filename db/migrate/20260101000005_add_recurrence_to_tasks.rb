class AddRecurrenceToTasks < ActiveRecord::Migration[7.1]
  def change
    add_column :tasks, :recurrence_type,     :string,  null: false, default: "once"
    add_column :tasks, :recurrence_interval, :integer, null: false, default: 1
    add_column :tasks, :monthly_day,         :integer, null: true
    add_column :tasks, :ends_on,             :date,    null: true

    add_index :tasks, :recurrence_type
  end
end