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
team = Team.first
10.times do
  name = Faker::Name.name
  Player.create!(name: name, team_id: team.id, position: "defesa", value: 20)
end