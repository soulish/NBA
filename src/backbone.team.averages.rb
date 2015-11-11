class TeamAverage
  include MethodMissing

  def initialize(codeyear,date,
                 pts,pf,fga,fgp,twoa,twop,threea,threep,fta,ftp,
                 ora,orp,dra,drp,tra,trp,asa,asp,sta,stp,bla,blp,toa,top,
                 dpts,dpf,dfga,dfgp,dtwoa,dtwop,dthreea,dthreep,dfta,dftp,
                 dora,dorp,ddra,ddrp,dtra,dtrp,dasa,dasp,
                 dsta,dstp,dbla,dblp,dtoa,dtop,num_games)
    @codeyear = codeyear
    @team = codeyear
    @date = date
    @pts = pts
    @pf = pf
    @num_games = num_games
    @fg = Pct.new((fgp*fga).round,fga)
    @two = Pct.new((twop*twoa).round,twoa)
    @three = Pct.new((threep*threea).round,threea)
    @ft = Pct.new((ftp*fta).round,fta)
    @ftmr = Pct.new((ftp*fta).round,fga)
    @or = Pct.new((orp*ora).round,ora)
    @dr = Pct.new((drp*dra).round,dra)
    @tr = Pct.new((trp*tra).round,tra)
    @as = Pct.new((asp*asa).round,asa)
    @st = Pct.new((stp*sta).round,sta)
    @bl = Pct.new((blp*bla).round,bla)
    @to = Pct.new((top*toa).round,toa)
    @efg = Pct.new((fgp*fga).round+0.5*(threep*threea).round,fga)

    @dpts = dpts
    @dpf = dpf
    @dfg = Pct.new((dfgp*dfga).round,dfga)
    @dtwo = Pct.new((dtwop*dtwoa).round,dtwoa)
    @dthree = Pct.new((dthreep*dthreea).round,dthreea)
    @dft = Pct.new((dftp*dfta).round,dfta)
    @dftmr = Pct.new((dftp*dfta).round,dfga)
    @dor = Pct.new((dorp*dora).round,dora)
    @ddr = Pct.new((ddrp*ddra).round,ddra)
    @dtr = Pct.new((dtrp*dtra).round,dtra)
    @das = Pct.new((dasp*dasa).round,dasa)
    @dst = Pct.new((dstp*dsta).round,dsta)
    @dbl = Pct.new((dblp*dbla).round,dbla)
    @dto = Pct.new((dtop*dtoa).round,dtoa)
    @defg = Pct.new((dfgp*dfga).round+0.5*(dthreep*dthreea).round,dfga)
  end

end
