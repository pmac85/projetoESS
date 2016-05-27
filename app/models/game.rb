class Game < ActiveRecord::Base
  belongs_to :journey
  belongs_to :team1, foreign_key: 'team1_id', class_name: 'Team'
  belongs_to :team2, foreign_key: 'team2_id', class_name: 'Team'

  def gerarResultado
    gol1=gol2=0
    game=self
    team1=game.team1
    team2=game.team2

    gk1=gk2=def1=def2=mid1=mid2=for1=for2=0

    team1.players.each do |player|
      if player.position == "GK" && player.is_active
        gk1+=player.value
      end
      if player.position == "DEF" && player.is_active
        def1+=player.value
      end
      if player.position == "MID" && player.is_active
        mid1+=player.value
      end
      if player.position == "FOR" && player.is_active
        for1+=player.value
      end
    end
    team2.players.each do |player|
      if player.position == "GK" && player.is_active
        gk2+=player.value
      end
      if player.position == "DEF" && player.is_active
        def2+=player.value
      end
      if player.position == "MID" && player.is_active
        mid2+=player.value
      end
      if player.position == "FOR" && player.is_active
        for2+=player.value
      end
    end



    team1GoalS=gk1+def1+(mid1/2)
    team2GoalS=gk2+def2+(mid2/2)

    team1GoalM=(mid1/2)+for1
    team2GoalM=(mid2/2)+for2

    #gol1=Random.new(6)
    #gol2=Random.new(6)
    difd = team1GoalS - team2GoalM
    difa = team2GoalS - team1GoalM
    rand1 = 2
    rand2 = 2

    equipa1=team1GoalM+team1GoalS
    equipa2=team2GoalM+team2GoalS

    if equipa1 > equipa2
      rand1+=2
    elsif equipa1<equipa2
      rand2+=2
    end

    #gerar golos
    if difd < 0
      rand2+=(difd).abs/100
    end

    if difa < 0
      rand1+=(difa).abs/100
    end

    gol1=Random.rand(rand1)
    gol2=Random.rand(rand2)

    if gol1>gol2
      team1.total_score += 3
      team1.victories += 1
      team2.defeats += 1
      user=User.where(id:team1_id)
      user.budget+=10
      user.save
    elsif gol1<gol2
      team2.total_score += 3
      team2.victories += 1
      team1.defeats += 1
      user=User.where(id:team2_id)
      user.budget+=10
      user.save
    else
      team1.total_score += 1
      team2.total_score += 1
      team1.draws += 1
      team2.draws += 1
      user=User.where(id:team1_id)
      user.budget+=5
      user.save
      user=User.where(id:team2_id)
      user.budget+=5
      user.save
    end
    game.team1_score = gol1
    game.team2_score = gol2

    game.save
    team1.save
    team2.save
  end
end
