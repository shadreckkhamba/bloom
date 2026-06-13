# Seed: Florence's account + wedding + sample guests
user = User.find_or_create_by!(email: "florence@example.com") do |u|
  u.name     = "Florence"
  u.password = "password123"
end

wedding = user.wedding || user.create_wedding!(
  bride_name:      "Florence",
  groom_name:      "Kelvin",
  wedding_date:    Date.new(2026, 12, 12),
  venue:           "Bingu International Convention Centre",
  theme:           "Gold & White",
  welcome_message: "We would be honored to celebrate this special day with you."
)

[
  { name: "John Banda",  phone: "0999123456" },
  { name: "Mary Phiri",  phone: "0888765432" },
  { name: "Peter Mbewe", phone: "0999987654" }
].each do |g|
  wedding.guests.find_or_create_by!(phone: g[:phone]) do |guest|
    guest.name = g[:name]
  end
end

puts "✅ Seeded: #{user.email} / password123"
puts "   Wedding: #{wedding.couple_names}"
puts "   Guests:  #{wedding.guests.count}"
wedding.guests.each { |g| puts "   #{g.name} → /i/#{g.token}" }
