class RemoveProfilePictureFromUsers < ActiveRecord::Migration[8.1]
  def change
    remove_column :users, :profile_picture, :string
  end
end
