class TeamGame < Game

  def initialize(team,opp,game_no,date,loc,win,pts,opp_pts,fgm,fga,
                 threem,threea,ftm,fta,orb,trb,ast,stl,blk,tov,pf,
                 opp_fgm,opp_fga,opp_threem,opp_threea,opp_ftm,opp_fta,
                 opp_orb,opp_trb,opp_ast,opp_stl,opp_blk,opp_tov,opp_pf)
    super(team,opp,date,loc,pts,fgm,fga,threem,threea,ftm,fta,
          orb,trb,ast,stl,blk,tov,pf)
    @game_no = game_no
    @win = win
    @poss = fga + tov + 0.44*fta# - orb

    ######
    @or = Pct.new(orb,orb + (opp_trb-opp_orb))
    @dr = Pct.new(trb-orb,(trb-orb) + opp_orb)
    @tr = Pct.new(trb,trb + opp_trb)
    @as = Pct.new(ast,fgm)
    @st = Pct.new(stl,poss)
    @bl = Pct.new(blk,poss)
    @to = Pct.new(tov,poss)
    # @efg = Pct.new(fgm+0.5*threem,fga)
    # @ftmr = Pct.new(ftm,fga)
    ######

    @opp_loc ||= "away" if loc == "home"
    @opp_loc ||= "home" if loc == "away"
    @opp_pts = opp_pts
    @dpts = opp_pts
    @dfg = Pct.new(opp_fgm,opp_fga)
    @dthree = Pct.new(opp_threem,opp_threea)
    @dtwo = Pct.new(opp_fgm - opp_threem,opp_fga - opp_threea)
    @dft = Pct.new(opp_ftm,opp_fta)
    @dor = Pct.new(opp_orb,opp_orb + (trb-orb))
    @ddr = Pct.new(opp_trb-opp_orb,(opp_trb-opp_orb) + orb)
    @dtr = Pct.new(opp_trb,opp_trb + trb)
    @das = Pct.new(opp_ast,opp_fga)
    @dposs = opp_fga + opp_tov + 0.44*opp_fta# - opp_orb
    @dst = Pct.new(opp_stl,dposs)
    @dbl = Pct.new(opp_blk,dposs)
    @dto = Pct.new(opp_tov,dposs)
    @dpf = opp_pf
    @defg = Pct.new(opp_fgm+0.5*opp_threem,opp_fga)
    @dftmr = Pct.new(opp_ftm,opp_fga)
  end
  
  def set_advanced(orating,drating,pace,ftr,threear,tsp,trp,asp,stp,blp,efgp,top,orp,ftmr,defgp,dtop,dorp,dftmr)
    @orating = orating
    @drating = drating
    @pace = pace
    ## @ftr = ftr
    ## @threear = threear
    ## @tsp = tsp
    ## @trp = trp
    ## @asp = asp
    ## @stp = stp
    ## @blp = blp
    ## @efgp = efgp
    ## @top = top
    ## @orp = orp
    ## @ftmr = ftmr
    ## @defgp = defgp
    ## @dtop = dtop
    ## @dorp = dorp
    ## @dftmr = dftmr
  end

end
