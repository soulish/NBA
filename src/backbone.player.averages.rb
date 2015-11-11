class PlayerAverage
  include MethodMissing

  def initialize(date,pts,mp,fga,fgp,twoa,twop,threea,threep,fta,ftp,
                 orm,orp,drm,drp,trm,trp,asm,asp,stm,stp,blm,blp,tom,top,num_games)
    @date = date
    @pts = pts
    @mp = mp
    @num_games = num_games
    @fg = Pct.new((fgp*fga).round,fga)
    @two = Pct.new((twop*twoa).round,twoa)
    @three = Pct.new((threep*threea).round,threea)
    @ft = Pct.new((ftp*fta).round,fta)
    @ftmr = Pct.new((ftp*fta).round,fga)

    tro = trp == 0 ? 0 : (trm/trp).round
    dro = drp == 0 ? 0 : (drm/drp).round
    oro = orp == 0 ? 0 : (orm/orp).round
    oro = tro - dro if (tro != 0 and oro == 0)
    dro = tro - oro if (tro != 0 and dro == 0)
    aso = asp == 0 ? 0 : (asm/asp).round
    sto = stp == 0 ? 0 : (stm/stp).round
    blo = blp == 0 ? 0 : (blm/blp).round
    too = top == 0 ? 0 : (tom/top).round

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

    @or = Pct.new(orm,oro,orp)
    @dr = Pct.new(drm,dro,drp)
    @tr = Pct.new(trm,tro,trp)
    @as = Pct.new(asm,aso,asp)
    @st = Pct.new(stm,sto,stp)
    @bl = Pct.new(blm,blo,blp)
    @to = Pct.new(tom,too,top)

    @efg = Pct.new((fgp*fga).round+0.5*(threep*threea).round,fga)
  end

end
