class TeamSeason < Season

  def initialize(year,team,g,wins,losses,pts,opp_pts,fgm,fga,threem,threea,ftm,fta,orb,trb,ast,stl,blk,tov,pf,
                 opp_fgm,opp_fga,opp_threem,opp_threea,opp_ftm,opp_fta,opp_orb,opp_trb,opp_ast,opp_stl,opp_blk,opp_tov,opp_pf,
                 poss,pace,orating,drating)
    super(year,team,g,fgm,fga,threem,threea,ftm,fta,
          orb,trb,ast,stl,blk,tov,pf,pts)
    @wins = wins
    @losses = losses
    @pct = wins/(wins+losses).to_f
    @wp = Pct.new(wins,wins+losses)

    @opp_pts = opp_pts
    @opp_fg = Pct.new(opp_fgm,opp_fga)
    @opp_two = Pct.new(opp_fgm-opp_threem,opp_fga-opp_threea)
    @opp_three = Pct.new(opp_threem,opp_threea)
    @opp_ft = Pct.new(opp_ftm,opp_fta)
    @opp_orb = opp_orb
    @opp_drb = opp_trb - opp_orb
    @opp_trb = opp_trb
    @opp_ast = opp_ast
    @opp_stl = opp_stl
    @opp_blk = opp_blk
    @opp_tov = opp_tov
    @opp_pf = opp_pf

    @poss = poss
    @pace = pace
    @orating = orating
    @drating = drating
    
    ######

    drb = trb - orb
    opp_drb = opp_trb - opp_orb
    @or = Pct.new(orb,orb + opp_drb)
    @dr = Pct.new(drb,drb + opp_orb)
    @tr = Pct.new(trb,trb + opp_trb)
    @as = Pct.new(ast,fgm)
    @st = Pct.new(stl,poss)
    @bl = Pct.new(blk,poss)
    @to = Pct.new(tov,poss)

    @defg = Pct.new(opp_fgm+0.5*opp_threem,opp_fga)
    @dto = Pct.new(opp_tov,poss)
    @dor = Pct.new(opp_orb,opp_orb+drb)
    @dftmr = Pct.new(opp_ftm,opp_fga)
    ######
  end

  def set_roster_stats_opening_day(g,gs,mp,fgm,fga,threem,threea,twom,twoa,ftm,fta,orb,oro,drb,dro,
                                   ast,aso,stl,sto,blk,blo,tov,too,pf,pts,ows,dws,ws,obpm,dbpm,bpm,vorp,per,gsp,wper,roster)
    trb = orb + drb
    tro = oro + dro
    @roster = roster
    @roster_g = g
    @roster_gs = gs
    @roster_mp = mp
    @roster_fg = Pct.new(fgm,fga)
    @roster_three = Pct.new(threem,threea)
    @roster_two = Pct.new(fgm-threem,fga-threea)
    @roster_ft = Pct.new(ftm,fta)

    ###Dividing by 5 here accounts for the fact that there are 5 players on the court
    ###at the same time with the same opportunities
    @roster_or = Pct.new(orb,oro/5.0)
    @roster_dr = Pct.new(drb,dro/5.0)
    @roster_tr = Pct.new(trb,tro/5.0)
    @roster_as = Pct.new(ast,aso/5.0)
    @roster_st = Pct.new(stl,sto/5.0)
    @roster_bl = Pct.new(blk,blo/5.0)
    @roster_to = Pct.new(tov,too-orb)

    @roster_pf = pf
    @roster_pts = pts
    @roster_ows = ows
    @roster_dws = dws
    @roster_ws = ws
    @roster_obpm = obpm
    @roster_dbpm = dbpm
    @roster_bpm = bpm
    @roster_vorp = vorp
    @roster_per = per
    @roster_wper = wper

    @roster_three_rate = Pct.new(threea,fga)
    @roster_ftr = Pct.new(fta,fga)
    @roster_ftmr = Pct.new(ftm,fga)
    @roster_efg = Pct.new(fgm+0.5*threem,fga)
    @roster_ts = Pct.new(pts,2*(fga+0.44*fta))

    @roster_owsp48 = Pct.new(5*48*ows,mp)
    @roster_dwsp48 = Pct.new(5*48*dws,mp)
    @roster_wsp48 =  Pct.new(5*48*ws, mp)

    @roster_gsp = Pct.new(gsp,$games_per_season[self.year-1])
  end
  alias_method :set_roster, :set_roster_stats_opening_day
end

