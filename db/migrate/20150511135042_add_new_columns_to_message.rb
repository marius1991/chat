class AddNewColumnsToMessage < ActiveRecord::Migration
  def change
    drop_table :messages

    create_table :messages

    add_column :messages, :timestamp, :integer
    add_column :messages, :recipientname, :string
    add_column :messages, :sig_service, :string
    add_column :messages, :name, :string
    add_column :messages, :cipher, :string
    add_column :messages, :iv, :string
    add_column :messages, :key_recipient_enc, :string
    add_column :messages, :sig_recipient, :string
  end
end
