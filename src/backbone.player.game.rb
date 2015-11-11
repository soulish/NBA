class PlayerGame < Game

  def initialize(season,car_game_no,date,age,loc,team,opp,margin,
                 gs,mp,fgm,fga,threem,threea,ftm,fta,orb,drb,trb,
                 ast,stl,blk,tov,pf,pts,game_score)
    fga = season < 1984 ? 0 : fga ##fgas were not recorded before 1984
    threea = season < 1986 ? 0 : threea#threeas not recorded before 1986
    fgm = threem if threem > fgm #there are a few games which
    fga = threea if threea > fga #didn't properly record fgm or fga
    super(team,opp,date,loc,pts,fgm,fga,threem,threea,ftm,fta,
          orb,trb,ast,stl,blk,tov,pf)
    @season = season
    @car_game_no = car_game_no
    @age = age
    @margin = margin
    @gs = gs
    @mp = mp
    @game_score = game_score

    #These are set up incorrectly here, then set properly in set_advanced
    @or = Pct.new(orb,trb)###This is only valid for getting or.m, not or.a!!!!!!
    @dr = Pct.new(drb,trb)###This is only valid for getting or.m, not or.a!!!!!!
    @tr = Pct.new(trb,5*trb)###This is only valid for getting or.m, not or.a!!!!!!
    @as = Pct.new(ast,5*ast)###This is only valid for getting or.m, not or.a!!!!!!
    @st = Pct.new(stl,5*stl)###This is only valid for getting or.m, not or.a!!!!!!
    @bl = Pct.new(blk,5*blk)###This is only valid for getting or.m, not or.a!!!!!!
    @to = Pct.new(tov,5*tov)###This is only valid for getting to.m, not to.a!!!!!!

    @fantasy_points = pts + 0.5*threem + 1.25*trb + 1.5*ast + 2*stl + 2*blk - 0.5*tov
    doubles = 0
    doubles += 1 if pts >= 10
    doubles += 1 if trb >= 10
    doubles += 1 if ast >= 10
    doubles += 1 if stl >= 10
    doubles += 1 if blk >= 10
    @fantasy_points += 1.5 if doubles == 2 #double-double bonus
    @fantasy_points += 3 if doubles >= 3 #triple-double bonus
  end

  def set_advanced(tsp,efg,orp,drp,trp,asp,stp,blp,top,usp,
                   orating,drating)
    #We have the percentages for a lot of stats, but not
    #the number of attempts for that stat.  So I have to
    #approximate here.  It is usually valid, unless
    #the player did not succeed in any attempts, then
    #his percentage is 0, and we have to make a smart guess
    tro = trp == 0 ? 0 : (@tr.m/trp).round
    dro = drp == 0 ? 0 : (@dr.m/drp).round
    oro = orp == 0 ? 0 : (@or.m/orp).round
    oro = tro - dro if (tro != 0 and oro == 0)
    dro = tro - oro if (tro != 0 and dro == 0)
    aso = asp == 0 ? 0 : (@as.m/asp).round
    sto = stp == 0 ? 0 : (@st.m/stp).round
    blo = blp == 0 ? 0 : (@bl.m/blp).round
    too = top == 0 ? 0 : (@to.m/top).round

    if aso <= 0
      if sto != 0
        aso = (0.33*sto).round
      elsif tro != 0
        aso = (0.36*tro).round
      end
    end

    if sto <= 0
      if ast != 0
        sto = (3*aso).round
      end
    end

    if blo <= 0
      if sto != 0
        blo = (2.25*sto).round
      end
    end

    @or = Pct.new(@or.m,oro,orp)
    @dr = Pct.new(@dr.m,dro,drp)
    @tr = Pct.new(@tr.m,tro,trp)
    @as = Pct.new(@as.m,aso,asp)
    @st = Pct.new(@st.m,sto,stp)
    @bl = Pct.new(@bl.m,blo,blp)
    @to = Pct.new(@to.m,too,top)

    @usp = usp
    @orating = orating
    @drating = drating
  end
end
