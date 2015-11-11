class Game

  include MethodMissing

  def initialize(team,opp,date,loc,pts,fgm,fga,threem,threea,ftm,fta,
                 orb,trb,ast,stl,blk,tov,pf)
    @team = team
    @opp = opp
    @date = date
    @loc = loc
    @pts = pts
    @fg = Pct.new(fgm,fga)
    @two = Pct.new(fgm - threem,fga - threea)
    @three = Pct.new(threem,threea)
    @ft = Pct.new(ftm,fta)
    @efg = Pct.new(fgm+0.5*threem,fga)
    @ts = Pct.new(pts,fga+0.44*fta)
    @ftmr = Pct.new(ftm,fga)
    @pf = pf
    # @orb = orb
    # @drb = trb - orb
    # @trb = trb
    # @ast = ast
    # @stl = stl
    # @blk = blk
    # @tov = tov
  end

end
