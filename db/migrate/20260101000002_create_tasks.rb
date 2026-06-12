class CreateTasks < ActiveRecord::Migration[7.1]
  def change
    create_table :tasks do |t|
      t.references :user, null: false, foreign_key: true
      t.string  :title, null: false
      t.text    :description
      t.string  :state, null: false, default: "active"
      t.date    :starts_on, null: false
      t.integer :lock_version, null: false, default: 0

      t.timestamps
    end

    add_index :tasks, %i[user_id state]
    add_index :tasks, :starts_on
  end
end