class Season
  
  include MethodMissing

  attr_reader :year

  def initialize(year,team,g,fgm,fga,threem,threea,ftm,fta,
                 orb,trb,ast,stl,blk,tov,pf,pts)
    @year = year; alias :season :year
    @team = team
    @g = g
    @fg = Pct.new(fgm,fga)
    @two = Pct.new(fgm-threem,fga-threea)
    @three = Pct.new(threem,threea)
    @ft = Pct.new(ftm,fta)
    # @orb = orb
    # @drb = trb-orb
    # @trb = trb
    # @ast = ast
    # @stl = stl
    # @blk = blk
    # @tov = tov
    @pf = pf
    @pts = pts

    ####

    @ts = Pct.new(pts,2*(fga+0.44*fta))
    @three_rate_pct = Pct.new(threea,fga)
    @ftr_pct = Pct.new(fta,fga)
    @ftmr = Pct.new(ftm,fga)
    @efg = Pct.new(fgm+0.5*threem,fga)
    ####
  end
end
