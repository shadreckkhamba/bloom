namespace :data do
  desc "Set default theme on weddings that have none"
  task set_default_theme: :environment do
    updated = Wedding.where(theme: [nil, ""]).update_all(theme: "Light Blue, Black, White, Nude")
    puts "Updated #{updated} wedding(s) with default theme."
  end
end
