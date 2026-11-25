# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

#user1 = User.find_or_create_by!(first_name: "Megui", last_name: "Ann", email: "megui.ann@gmail.com", password: "123456")

user1 = User.find_or_create_by!(email: "megui.ann@gmail.com") do |u|
  u.password = "123456"
  u.password_confirmation = "123456"
end

outfit2= Outfit.find_or_create_by!(name: "Night out look", season: "Autumn", details: "Black top, Black skirt, Black boots.", image: "123", user: user1);
puts outfit2

chat1 = Chat.find_or_create_by!(user: user1, outfit: outfit2)
