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

#----------------------------------------------------------------------------------#
#                                                                                  #
#                                                                                  #
#                                  Players                                         #
#                                                                                  #
#                                                                                  #
#----------------------------------------------------------------------------------#




# League
League.create!(name: "Liga NOS")

# Teams
league = League.first
50.times do |n|
  name = Faker::Team.name
  Team.create!(name: name, user_id: n+1, league_id: league.id, budget: 500,
               image_path: "http://media1.fcbarcelona.com/media/asset_publics/resources/000/004/670/original_rgb/FCB.v1319559431.png")
end

# Players
teams = Team.order(:created_at).take(10)
2.times do
  name = Faker::Name.name
  teams.each { |team| Player.create!(name: name, team_id: team.id, position: "GK", value: 15, isChosen: true, is_active: (Random.new.rand(2) == 0),
                                     image_path: "http://futhead.cursecdn.com/static/img/14/players/158023.png")}
end
5.times do
  name = Faker::Name.name
  teams.each { |team| Player.create!(name: name, team_id: team.id, position: "DEF", value: 20, isChosen: true, is_active: (Random.new.rand(2) == 0),
                                     image_path: "http://futhead.cursecdn.com/static/img/14/players/158023.png")}
end
5.times do
  name = Faker::Name.name
  teams.each { |team| Player.create!(name: name, team_id: team.id, position: "MID", value: 25, isChosen: true, is_active: (Random.new.rand(2) == 0),
                                     image_path: "http://futhead.cursecdn.com/static/img/14/players/158023.png")}
end
3.times do
  name = Faker::Name.name
  teams.each { |team| Player.create!(name: name, team_id: team.id, position: "FOR", value: 40, isChosen: true, is_active: (Random.new.rand(2) == 0),
                                     image_path: "http://futhead.cursecdn.com/static/img/14/players/158023.png")}
end