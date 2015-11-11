class PlayerSeason < Season

  def initialize(year,team,pos,g,gs,mp,fgm,fga,threem,threea,ftm,fta,orb,drb,ast,stl,blk,tov,pf,pts,efgp)
    super(year,team,g,fgm,fga,threem,threea,ftm,fta,
          orb,(orb+drb),ast,stl,blk,tov,pf,pts)
    @pos = pos
    @gs = gs
    @mp = mp
    @efgp = efgp

    @fg_pmp = Pct.new(fga,mp)
    @two_pmp = Pct.new(fga-threea,mp)
    @three_pmp = Pct.new(threea,mp)
    @ft_pmp = Pct.new(fta,mp)

    @mpg = Pct.new(mp,48*g)

    @or = Pct.new(orb,orb+drb)###This is only valid for getting or.m, not or.a!!!!!!
    @dr = Pct.new(drb,orb+drb)###This is only valid for getting or.m, not or.a!!!!!!
    @tr = Pct.new(orb+drb,5*(orb+drb))###This is only valid for getting or.m, not or.a!!!!!!
    @as = Pct.new(ast,5*ast)###This is only valid for getting or.m, not or.a!!!!!!
    @st = Pct.new(stl,5*stl)###This is only valid for getting or.m, not or.a!!!!!!
    @bl = Pct.new(blk,5*blk)###This is only valid for getting or.m, not or.a!!!!!!
    @to = Pct.new(tov,5*tov)###This is only valid for getting to.m, not to.a!!!!!!
  end

  def set_advanced(tsp,three_rate,ftr,orp,drp,trp,asp,stp,blp,top,usp,ows,dws,ws,wsp48,obpm,dbpm,bpm,vorp,per)
    orp = (orp/100.0).to_N(3) #convert from percentages to decimals
    drp = (drp/100.0).to_N(3)
    trp = (trp/100.0).to_N(3)
    asp = (asp/100.0).to_N(3)
    stp = (stp/100.0).to_N(3)
    blp = (blp/100.0).to_N(3)
    top = (top/100.0).to_N(3)

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

    # @tsp = tsp
    # @three_rate = three_rate
    # @ftr = ftr
    # @orp = (orp/100.0).to_N(3)
    # @drp = (drp/100.0).to_N(3)
    # @trp = (trp/100.0).to_N(3)
    # @asp = (asp/100.0).to_N(3)
    # @stp = (stp/100.0).to_N(3)
    # @blp = (blp/100.0).to_N(3)
    # @top = (top/100.0).to_N(3)

    # @tro = @trp == 0 ? 0 : (@trb/@trp).round
    # @dro = @drp == 0 ? 0 : (@drb/@drp).round
    # @oro = @orp == 0 ? 0 : (@orb/@orp).round
    # @oro = @tro - @dro if (@tro != 0 and @oro == 0)
    # @dro = @tro - @oro if (@tro != 0 and @dro == 0)
    # @aso = @asp == 0 ? 0 : (@ast/@asp).round
    # @sto = @stp == 0 ? 0 : (@stl/@stp).round
    # @blo = @blp == 0 ? 0 : (@blk/@blp).round
    # @too = @top == 0 ? 0 : (@tov/@top).round

    # if @aso == 0
    #   if @sto != 0
    #     @aso = (0.33*@sto).round
    #   elsif @tro != 0
    #     @aso = (0.36*@tro).round
    #   end
    # end

    # if @sto == 0
    #   if @ast != 0
    #     @sto = (3*@aso).round
    #   end
    # end

    # if @blo == 0
    #   if @sto != 0
    #     @blo = (2.25*@sto).round
    #   end
    # end

    @usp = (usp/100.0).to_N(3)
    @ows = ows.to_N(1)
    @dws = dws.to_N(1)
    @ws = ws.to_N(1)
    @wsp48 = wsp48.to_N(3)
    @obpm = obpm.to_N(1)
    @dbpm = dbpm.to_N(1)
    @bpm = bpm.to_N(1)
    @vorp = vorp.to_N(1)
    @per = per.to_N(1)
  end

  def setage(age)
    @age = age
  end

  def set_gsp(gsp_sum,gsp_g,gsp_w)
    @gsp_sum = gsp_sum
    @gsp_g = gsp_g
    @gsp_w = gsp_w
    @gsp = gsp_sum/gsp_g.to_f*gsp_w
    @gsp48 = 48*@gsp/@mp.to_f
  end

  def findteammates
    teammates = []
    team = self.team
    year = self.year
    Player.each do |player|
      next unless year.in_between(player.start_year,player.end_year)
      player.seasons.each do |season|
        teammates.push player if (team == season.team and year == season.year)
      end
    end
    teammates
  end
end

