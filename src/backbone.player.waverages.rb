class PlayerWAverage < PlayerAverage
  include MethodMissing

  def initialize(date,pts,mp,fga,fgp,twoa,twop,threea,threep,fta,ftp,
                 orm,orp,drm,drp,trm,trp,asm,asp,stm,stp,blm,blp,tom,top,num_games)
    ##note, I've set asm and asp to 0 because they don't get weighted
    ##properly.
    super(date,pts,mp,fga,fgp,twoa,twop,threea,threep,fta,ftp,
          orm,orp,drm,drp,trm,trp,0,0,stm,stp,blm,blp,tom,top,num_games)
  end
end
