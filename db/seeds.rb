# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


return if User.find_by(name: 'user1')

users = (1..100000).map do |i|
  {
    name: "user#{i}",
    birthday: Time.zone.local(2020, i % 12 + 1, i % 28 + 1)
  }
end

User.insert_all(users)
