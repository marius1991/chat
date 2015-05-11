class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :name
      t.string :password
      t.string :public_key
      t.string :private_key
      t.string :salt_master_key

      t.timestamps null: false
    end
  end
end
