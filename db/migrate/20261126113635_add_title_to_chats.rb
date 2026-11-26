class AddTitleToChats < ActiveRecord::Migration[8.1]
  def change
    add_column :chats, :title, :string, default: "Untitled"
  end
end
