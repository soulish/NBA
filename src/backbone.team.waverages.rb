class TeamWAverage < TeamAverage
  include MethodMissing

  def initialize(codeyear,date,
                 pts,pf,fga,fgp,twoa,twop,threea,threep,fta,ftp,
                 ora,orp,dra,drp,tra,trp,asa,asp,sta,stp,bla,blp,toa,top,
                 dpts,dpf,dfga,dfgp,dtwoa,dtwop,dthreea,dthreep,dfta,dftp,
                 dora,dorp,ddra,ddrp,dtra,dtrp,dasa,dasp,
                 dsta,dstp,dbla,dblp,dtoa,dtop,
                 srs,sos,pure_wp,alt_wp,num_games)
    super(codeyear,date,pts,pf,fga,fgp,twoa,twop,threea,threep,fta,ftp,
                 ora,orp,dra,drp,tra,trp,asa,asp,sta,stp,bla,blp,toa,top,
                 dpts,dpf,dfga,dfgp,dtwoa,dtwop,dthreea,dthreep,dfta,dftp,
                 dora,dorp,ddra,ddrp,dtra,dtrp,dasa,dasp,
                 dsta,dstp,dbla,dblp,dtoa,dtop,num_games)

    @srs = srs
    @sos = sos
    @pure_wp = pure_wp
    @alt_wp = alt_wp
  end
end
