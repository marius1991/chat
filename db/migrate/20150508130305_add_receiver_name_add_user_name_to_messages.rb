class AddReceiverNameAddUserNameToMessages < ActiveRecord::Migration
  def change
    add_column :messages, :user_name, :string
    add_column :messages, :receiver_name, :string
  end
end
