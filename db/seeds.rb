User.create!(username:  "ExampleUser",
             email:     "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)



99.times do |n|
  username = Faker::Name.name
  email    = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(username:  username,
               email:     email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

# League
League.create!(name: "Liga NOS")

# Teams
user = User.first
league = League.first
50.times do
  name = Faker::Team.name
  Team.create!(name: name, user_id: user.id, league_id: league.id)
end

# Players
teams = Team.order(:created_at).take(10)
1.times do
  name = Faker::Name.name
  teams.each { |team| Player.create!(name: name, team_id: team.id, position: "Guarda-Redes", value: 15)}
end
4.times do
  name = Faker::Name.name
  teams.each { |team| Player.create!(name: name, team_id: team.id, position: "Defesa", value: 20)}
end
4.times do
  name = Faker::Name.name
  teams.each { |team| Player.create!(name: name, team_id: team.id, position: "Medio", value: 25)}
end
2.times do
  name = Faker::Name.name
  teams.each { |team| Player.create!(name: name, team_id: team.id, position: "Avançado", value: 40)}
end