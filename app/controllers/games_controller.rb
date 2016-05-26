class GamesController < ApplicationController

  def show
    @game=Game.find(params[:id])
  end

  def gerarResultado
    gol1=gol2=0
    game=Game.find(params[:id])
    team1=game.team1
    team2=game.team2

    players1=team1.players
    players2=team2.players

    gk1=gk2=def1=def2=mid1=mid2=for1=for2=0
    s=0
    begin
      if(players1.find(s).position.equal?("GK") && players1.find(s).is_active)
        gk1+=players1.find(s).value
      end
      if(players1.find(s).position.equal?("DEF") && players1.find(s).is_active)
        def1+=players1.find(s).value
      end
      if(players1.find(s).position.equal?("MID") && players1.find(s).is_active)
        mid1+=players1.find(s).value
      end
      if(players1.find(s).position.equal?("FOR") && players1.find(s).is_active)
        for1+=players1.find(s).value
      end
      if(players2.find(s).position.equal?("GK") && players2.find(s).is_active)
        gk2+=players2.find(s).value
      end
      if(players2.find(s).position.equal?("DEF") && players2.find(s).is_active)
        def2+=players2.find(s).value
      end
      if(players2.find(s).position.equal?("MID") && players2.find(s).is_active)
        mid2+=players2.find(s).value
      end
      if(players2.find(s).position.equal?("FOR") && players2.find(s).is_active)
        for2+=players2.find(s).value
      end
    end while(s<players1.count())

    team1GoalA=gk1+def1+(mid1/2)
    team2GoalA=gk2+def2+(mid2/2)

    team1GoalM=(mid1/2)+for1;
    team2GoalM=(mid2/2)+for2;

    valueRandom1=Random.new(6);
    valueRandom2=Random.new(6);


    #gerar golos


    if(gol1>gol2)
      team1.total_score+=3;
      team1.victories+=1;
      team2.defeats+=1;

    else if(gol1<gol2)
      team2.total_score+=3;
      team2.victories+=1;
      team1.defeats+=1;

         else
           team1.total_score+=1;
           team2.total_score+=1;
           team1.draws+=1;
           team2.draws+=1;
           end
    end

    game.save
    team1.save
    team2.save
  end


end
