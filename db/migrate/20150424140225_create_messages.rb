class CreateMessages < ActiveRecord::Migration
  def change
    create_table :messages do |t|
      t.string :text
      t.integer :receiver_id
      t.integer :user_id

      t.timestamps null: false
    end
  end
end
