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

outfit1= Outfit.find_or_create_by!(name: "Night out look", season: "Autumn", details: "Burgundy top, Black skirt, Black boots, Black leather jacket.", image: "123", user: user1);

outfit2= Outfit.find_or_create_by!(name: "Casual look for drinks", season: "Summer", details: "Sparkle jeans, Pink Top, Brown sandals.", image: "123", user: user1);

outfit3= Outfit.find_or_create_by!(name: "Hiking look", season: "Winter", details: "Bege pants, White shirt, White jacket, Hiking boots.", image: "123", user: user1);

chat1 = Chat.find_or_create_by!(user: user1, outfit: outfit1)
chat2 = Chat.find_or_create_by!(user: user1, outfit: outfit2)
chat3 = Chat.find_or_create_by!(user: user1, outfit: outfit3)
