class Team

  def calc_totals
    stats = ["fg","two","three","ft","or","dr","tr","to"]
    stats.each{|s| ["m","a","p"].each{|m| @totals["#{s}.#{m}"] = {}}}
    stats.each{|s| ["m","a","p"].each{|m| @totals["d#{s}.#{m}"] = {}}}
    @totals["efg.p"] = {}; @totals["ftmr.p"] = {}
    @totals["defg.p"] = {}; @totals["dftmr.p"] = {}
    @games.length.times do |ii|
      i = ii+1
      stats.each do |s| 
        ["m","a"].each do |m|
          @totals["#{s}.#{m}"][i] = @games[i].stats("#{s}.#{m}") if i == 1
          @totals["#{s}.#{m}"][i] = @totals["#{s}.#{m}"][i-1] + @games[i].stats("#{s}.#{m}") unless i == 1

          @totals["d#{s}.#{m}"][i] = @games[i].stats("d#{s}.#{m}") if i == 1
          @totals["d#{s}.#{m}"][i] = @totals["d#{s}.#{m}"][i-1] + @games[i].stats("d#{s}.#{m}") unless i == 1
        end
        @totals["#{s}.p"][i] = (@totals["#{s}.m"][i]/@totals["#{s}.a"][i].to_f).to_N(3)
        @totals["d#{s}.p"][i] = (@totals["d#{s}.m"][i]/@totals["d#{s}.a"][i].to_f).to_N(3)
      end
      @totals["efg.p"][i] = ((@totals["fg.m"][i] + 0.5*@totals["three.m"][i])/@totals["fg.a"][i].to_f).to_N(3)
      @totals["ftmr.p"][i] = (@totals["ft.m"][i]/@totals["fg.a"][i].to_f).to_N(3)

      @totals["defg.p"][i] = ((@totals["dfg.m"][i] + 0.5*@totals["dthree.m"][i])/@totals["dfg.a"][i].to_f).to_N(3)
      @totals["dftmr.p"][i] = (@totals["dft.m"][i]/@totals["dfg.a"][i].to_f).to_N(3)
    end
  end

  def calc_weighted_averages_alt(date)
    #correct as of 2015/03/01
    year = self.year
    stats = ["pts","pf",
             "fg.a","fg.p","two.a","two.p","three.a","three.p","ft.a","ft.p",
             "or.a","or.p","dr.a","dr.p","tr.a","tr.p",
             "as.a","as.p","st.a","st.p","bl.a","bl.p","to.a","to.p"]
    totals = {}; stats.each{|s| totals[s] = 0;totals["d#{s}"] = 0}
    wins, losses, opp_wins, opp_losses, opp_opp_wins, opp_opp_losses = 0,0,{},{},0,0 ###
    alt_wins, alt_total, pure_wins, pure_total = 0,0,0,0
    srs = 0;pt_diff = 0;opp_avg_pt_diff = 0
    stat = {}; stats.each{|i| stat[i] = 0;stat["d#{i}"] = 0}
    opp_sums = {}; num_opp_games = {}; opp_alt_wins = {}; opp_alt_total= {}; opp_pt_diff = {}

    num_games = 0
    games.each do |k,game|
      next unless game.date < date

      stats.each{|s| totals[s] += game.stats(s); totals["d#{s}"] += game.stats("d#{s}")}
      num_games += 1
      pure_total += 1
      pure_wins += 1 if game.pts > game.opp_pts
      if game.pts > game.opp_pts
        wins += 1.4 if game.loc == "away"
        wins += 0.6 if game.loc == "home"
      elsif game.pts < game.opp_pts
        losses += 0.6 if game.loc == "away"
        losses += 1.4 if game.loc == "home"
      end
      pt_diff += game.pts - game.opp_pts
      
      oname = "#{year} #{game.opp}"
      opp = Team.findteam(oname)

      #only go through this the first time only for each opponent
      if opp_sums[oname].nil?
        opp_sums[oname] = {}
        stats.each{|i| opp_sums[oname][i] = 0; opp_sums[oname]["d#{i}"] = 0}
        num_opp_games[oname] = 0
        opp_alt_wins[oname],opp_alt_total[oname] = 0,0
        opp_pt_diff[oname] = 0
        opp_wins[oname] ||= 0; opp_losses[oname] ||= 0
        opp.games.each do |index,opp_game|
          next unless opp_game.date < date
          next if opp_game.opp == self.code
          num_opp_games[oname] += 1
          opp_wins[oname]   += 1 if opp_game.pts > opp_game.opp_pts
          opp_losses[oname] += 1 if opp_game.pts < opp_game.opp_pts
          opp_pt_diff[oname] += opp_game.pts - opp_game.opp_pts
          
          stats.each do |i|
            opp_sums[oname][i] += (opp_game.stats("d#{i}")*$neutral_ratio_by_year[year][i][opp_game.opp_loc]/$team_5yr_averages[year][i][0])
            opp_sums[oname]["d#{i}"] += (opp_game.stats(i)*$neutral_ratio_by_year[year][i][opp_game.loc]/$team_5yr_averages[year][i][0])
          end
          opp_alt_wins[oname] += $ratio_win_by_year[year][opp_game.loc]
          opp_alt_total[oname] += $ratio_win_by_year[year][opp_game.loc]
        end
      end
      
      opp_avg_pt_diff += opp_pt_diff[oname]/num_opp_games[oname].to_f###
      stats.each do |i|
        if (num_opp_games[oname] > 0 and opp_sums[oname][i] > 0)
          stat[i] += game.stats(i)*$neutral_ratio_by_year[year][i][game.loc]/(opp_sums[oname][i]/num_opp_games[oname].to_f) 
          stat["d#{i}"] += game.stats("d#{i}")*$neutral_ratio_by_year[year][i][game.opp_loc]/(opp_sums[oname]["d#{i}"]/num_opp_games[oname].to_f) 
        else
          stat[i] += game.stats(i)*$neutral_ratio_by_year[year][i][game.loc] #only when the opp exists, but hasn't played a game yet
          stat["d#{i}"] += game.stats("d#{i}")*$neutral_ratio_by_year[year][i][game.opp_loc]
        end
      end
      if opp_alt_wins[oname] > 0
        alt_wins += $ratio_win_by_year[year][game.loc]/(opp_alt_wins[oname]/(0.5*opp_alt_total[oname].to_f)) if game.pts > game.opp_pts
        alt_total += $ratio_win_by_year[year][game.loc]/(opp_alt_wins[oname]/(0.5*opp_alt_total[oname].to_f))
      else
        alt_wins += $ratio_win_by_year[year][game.loc] if game.pts > game.opp_pts
        alt_total += $ratio_win_by_year[year][game.loc]
      end
    end

    srs = (pt_diff + opp_avg_pt_diff)/num_games.to_f
    sos = opp_avg_pt_diff/num_games.to_f

    stats.each do |i|
      next unless i.include?(".p")
      stat[i] = stat[i]/num_games.to_f if num_games > 0
      stat["d#{i}"] = stat["d#{i}"]/num_games.to_f if num_games > 0
      totals[i] = totals[i]/num_games.to_f if num_games > 0
      totals["d#{i}"] = totals["d#{i}"]/num_games.to_f if num_games > 0
    end

    [stat,totals,srs,sos,pure_wins/pure_total.to_f,alt_wins/alt_total.to_f,num_games]
  end

  def recalc_srs(date)
    #correct as of 2015-03-01
    srs = 0; opp_srs = 0; num_opps = 0; pt_diff = 0
    stats = ["pts","pf",
             "fg.a","fg.p","two.a","two.p","three.a","three.p","ft.a","ft.p",
             "or.a","or.p","dr.a","dr.p","tr.a","tr.p",
             "as.a","as.p","st.a","st.p","bl.a","bl.p","to.a","to.p"]
    stat = {}
    stats.each{|i| stat[i] = 0}
    stats.each{|i| stat["d#{i}"] = 0}
    year = self.year
    results = []
    games.each do |k,game|
      next unless game.date < date
      opp = Team.findteam("#{year} #{game.opp}")
      opp_game = opp.games_by_date[game.date]
      opp_waverage = opp.waverages[date]

      ##skip games from beginning of the year with issues
      next if opp_waverage.nil?

      opp_srs += opp_waverage.srs
      num_opps += 1

      pt_diff += game.pts - game.opp_pts
      stats.each do |i|
        if i.include?(".p")
          stat[i] += game.stats(i)*$neutral_ratio_by_year[year][i][game.loc]*$team_5yr_averages[year][i][0]/opp_waverage.stats("d#{i}")
          stat["d#{i}"] += game.stats("d#{i}")*$neutral_ratio_by_year[year][i][game.opp_loc]*$team_5yr_averages[year][i][0]/opp_waverage.stats(i)#this is what opp gets
        else
          stat[i] += game.stats(i)*$neutral_ratio_by_year[year][i][game.loc]*$team_5yr_averages[year][i][0]/(opp_waverage.stats("d#{i}")/opp_waverage.num_games.to_f)
          stat["d#{i}"] += game.stats("d#{i}")*$neutral_ratio_by_year[year][i][game.opp_loc]*$team_5yr_averages[year][i][0]/(opp_waverage.stats(i)/opp_waverage.num_games.to_f)#this is what opp gets
        end
      end
    end
    srs = (pt_diff + opp_srs)/num_opps.to_f
    sos = opp_srs/num_opps.to_f
    stats.each do |i| 
      next unless i.include?(".p")
      stat[i] = stat[i]/num_opps.to_f 
      stat["d#{i}"] = stat["d#{i}"]/num_opps.to_f
    end
    [srs,sos,stat]
  end

end



  # def calc_weighted_averages(date)
  #   #correct as of 2015/02/28
  #   year = self.year
  #   #stats = ["or.m","or.a","fg.m","fg.a","three.m","three.a","ft.m","to.m","to.a"]
  #   stats = ["pts","pf",
  #            "fg.m","fg.a","two.m","two.a","three.m","three.a","ft.m","ft.a",
  #            "or.m","or.a","dr.m","dr.a","tr.m","tr.a",
  #            "as.m","as.a","st.m","st.a","bl.m","bl.a","to.m","to.a"]
  #   totals = {}
  #   stats.each{|s| totals[s] = 0;totals["d#{s}"] = 0}
  #   wins, losses, opp_wins, opp_losses, opp_opp_wins, opp_opp_losses = 0,0,0,0,0,0 ###
  #   alt_wins, alt_total, pure_wins, pure_total = 0,0,0,0
  #   srs = 0;pt_diff = 0;opp_avg_pt_diff = 0
  #   stat = {}
  #   stats.each{|i| stat[i] = 0;stat["d#{i}"] = 0}
  #   num_games = 0
  #   games.each do |k,game|
  #     next unless game.date < date

  #     stats.each{|s| totals[s] += game.stats(s); totals["d#{s}"] += game.stats("d#{s}")}
      
  #     opp = Team.findteam("#{year} #{game.opp}")
  #     opp_sum = {}
  #     stats.each{|i| opp_sum[i] = 0; opp_sum["d#{i}"] = 0}
  #     num_opp_games = 0
  #     num_games += 1
  #     pure_total += 1
  #     pure_wins += 1 if game.pts > game.opp_pts
  #     if game.pts > game.opp_pts
  #       wins += 1.4 if game.loc == "away"
  #       wins += 0.6 if game.loc == "home"
  #     elsif game.pts < game.opp_pts
  #       losses += 0.6 if game.loc == "away"
  #       losses += 1.4 if game.loc == "home"
  #     end
  #     pt_diff += game.pts - game.opp_pts
  #     opp_alt_wins,opp_alt_total = 0,0
  #     opp_pt_diff = 0
  #     opp.games.each do |index,opp_game|
  #       next unless opp_game.date < date
  #       next if opp_game.opp == self.code
  #       num_opp_games += 1
  #       opp_wins   += 1 if opp_game.pts > opp_game.opp_pts
  #       opp_losses += 1 if opp_game.pts < opp_game.opp_pts
  #       opp_pt_diff += opp_game.pts - opp_game.opp_pts

  #       stats.each do |i|
  #         opp_sum[i] += (opp_game.stats("d#{i}")*$neutral_ratio_by_year[year][i][opp_game.opp_loc]/$team_5yr_averages[year][i][0])
  #         opp_sum["d#{i}"] += (opp_game.stats(i)*$neutral_ratio_by_year[year][i][opp_game.loc]/$team_5yr_averages[year][i][0])
  #       end
  #       opp_alt_wins += $ratio_win_by_year[year][opp_game.loc]
  #       opp_alt_total += $ratio_win_by_year[year][opp_game.loc]
  #     end
  #     opp_avg_pt_diff += opp_pt_diff/num_opp_games.to_f###
      
  #     stats.each do |i|
  #       if (num_opp_games > 0 and opp_sum[i] > 0)
  #         stat[i] += game.stats(i)*$neutral_ratio_by_year[year][i][game.loc]/(opp_sum[i]/num_opp_games.to_f) 
  #         stat["d#{i}"] += game.stats("d#{i}")*$neutral_ratio_by_year[year][i][game.opp_loc]/(opp_sum["d#{i}"]/num_opp_games.to_f) 
  #       else
  #         stat[i] += game.stats(i)*$neutral_ratio_by_year[year][i][game.loc] #only when the opp exists, but hasn't played a game yet
  #         stat["d#{i}"] += game.stats("d#{i}")*$neutral_ratio_by_year[year][i][game.opp_loc]
  #       end
  #     end
  #     if opp_alt_wins > 0
  #       alt_wins += $ratio_win_by_year[year][game.loc]/(opp_alt_wins/(0.5*opp_alt_total.to_f)) if game.pts > game.opp_pts
  #       alt_total += $ratio_win_by_year[year][game.loc]/(opp_alt_wins/(0.5*opp_alt_total.to_f))
  #     else
  #       alt_wins += $ratio_win_by_year[year][game.loc] if game.pts > game.opp_pts
  #       alt_total += $ratio_win_by_year[year][game.loc]
  #     end
  #   end

  #   srs = (pt_diff + opp_avg_pt_diff)/num_games.to_f
  #   sos = opp_avg_pt_diff/num_games.to_f

  #   stats.each do |i|
  #     stat[i] = stat[i]/num_games.to_f if num_games > 0
  #     stat["d#{i}"] = stat["d#{i}"]/num_games.to_f if num_games > 0
  #     totals[i] = totals[i]/num_games.to_f if num_games > 0
  #     totals["d#{i}"] = totals["d#{i}"]/num_games.to_f if num_games > 0
  #   end

  #   [stat,totals,srs,sos,pure_wins/pure_total.to_f,alt_wins/alt_total.to_f]
  # end

  # def calc_weighted_averages(date)
  #   #correct as of 2015/02/21
  #   year = self.year
  #   stats = ["or.m","or.a","fg.m","fg.a","three.m","three.a","ft.m","to.m","to.a"]
  #   totals = {}
  #   stats.each{|s| totals[s] = 0}
  #   wins, losses, opp_wins, opp_losses, opp_opp_wins, opp_opp_losses = 0,0,0,0,0,0 ###
  #   alt_wins, alt_total, pure_wins, pure_total = 0,0,0,0
  #   srs = 0;pt_diff = 0;opp_avg_pt_diff = 0
  #   stat = {}
  #   stats.each{|i| stat[i] = 0}
  #   num_games = 0
  #   games.each do |k,game|
  #     next unless game.date < date

  #     stats.each do |s| 
  #       totals[s] += game.stats(s)
  #     end
      
  #     opp = Team.findteam("#{year} #{game.opp}")
  #     opp_sum = {}
  #     stats.each{|i| opp_sum[i] = 0}
  #     num_opp_games = 0
  #     num_games += 1
  #     pure_total += 1
  #     pure_wins += 1 if game.pts > game.opp_pts
  #     if game.pts > game.opp_pts
  #       wins += 1.4 if game.loc == "away"
  #       wins += 0.6 if game.loc == "home"
  #     elsif game.pts < game.opp_pts
  #       losses += 0.6 if game.loc == "away"
  #       losses += 1.4 if game.loc == "home"
  #     end
  #     pt_diff += game.pts - game.opp_pts
  #     opp_alt_wins,opp_alt_total = 0,0
  #     opp_pt_diff = 0
  #     opp.games.each do |index,opp_game|
  #       next unless opp_game.date < date
  #       next if opp_game.opp == self.code
  #       num_opp_games += 1
  #       opp_wins   += 1 if opp_game.pts > opp_game.opp_pts
  #       opp_losses += 1 if opp_game.pts < opp_game.opp_pts
  #       opp_pt_diff += opp_game.pts - opp_game.opp_pts

  #       stats.each do |i|
  #         opp_sum[i] += (opp_game.stats("d#{i}")*$neutral_ratio_by_year[year][i][opp_game.opp_loc]/$neutral_averages_by_year[year][i])
  #       end
  #       opp_alt_wins += $ratio_win_by_year[year][opp_game.loc]
  #       opp_alt_total += $ratio_win_by_year[year][opp_game.loc]
  #     end
  #     opp_avg_pt_diff += opp_pt_diff/num_opp_games.to_f###
      
  #     stats.each do |i|
  #       if (num_opp_games > 0 and opp_sum[i] > 0)
  #         stat[i] += game.stats(i)*$neutral_ratio_by_year[year][i][game.loc]/(opp_sum[i]/num_opp_games.to_f) 
  #       else
  #         stat[i] += game.stats(i)*$neutral_ratio_by_year[year][i][game.loc] #only when the opp exists, but hasn't played a game yet
  #       end
  #     end
  #     if opp_alt_wins > 0
  #       alt_wins += $ratio_win_by_year[year][game.loc]/(opp_alt_wins/(0.5*opp_alt_total.to_f)) if game.pts > game.opp_pts
  #       alt_total += $ratio_win_by_year[year][game.loc]/(opp_alt_wins/(0.5*opp_alt_total.to_f))
  #     else
  #       alt_wins += $ratio_win_by_year[year][game.loc] if game.pts > game.opp_pts
  #       alt_total += $ratio_win_by_year[year][game.loc]
  #     end
  #   end

  #   srs = (pt_diff + opp_avg_pt_diff)/num_games.to_f
  #   sos = opp_avg_pt_diff/num_games.to_f

  #   stats.each do |i|
  #     stat[i] = stat[i]/num_games.to_f if num_games > 0
  #     totals[i] = totals[i]/num_games.to_f if num_games > 0
  #   end

  #   [stat,totals,srs,sos,pure_wins/pure_total.to_f,alt_wins/alt_total.to_f]
  # end

  # def calc_opp_weighted_averages(date)
  #   #correct as of 2015/02/21
  #   year = self.year
  #   stats = ["or.m","or.a","fg.m","fg.a","three.m","three.a","ft.m","to.m","to.a"]
  #   totals = {}
  #   stats.each{|s| totals["d#{s}"] = 0}
  #   stat = {}
  #   stats.each{|i| stat[i] = 0}
  #   num_games = 0
  #   games.each do |k,game|
  #     next unless game.date < date

  #     stats.each{|s| totals["d#{s}"] += game.stats("d#{s}")}

  #     opp = Team.findteam("#{year} #{game.opp}")
  #     opp_sum = {}
  #     stats.each{|i| opp_sum[i] = 0}
  #     num_opp_games = 0
  #     num_games += 1
  #     opp.games.each do |index,opp_game|
  #       next unless opp_game.date < date
  #       next if opp_game.opp == self.code
  #       num_opp_games += 1
  #       stats.each{|i| opp_sum[i] += (opp_game.stats(i)*$neutral_ratio_by_year[year][i][opp_game.loc]/$neutral_averages_by_year[year][i])}
  #     end
      
  #     stats.each do |i|
  #       if (num_opp_games > 0 and opp_sum[i] > 0)
  #         stat[i] += game.stats("d#{i}")*$neutral_ratio_by_year[year][i][game.opp_loc]/(opp_sum[i]/num_opp_games.to_f) 
  #       else
  #         stat[i] += game.stats("d#{i}")*$neutral_ratio_by_year[year][i][game.opp_loc] #only when the opp exists, but hasn't played a game yet
  #       end
  #     end
  #   end

  #   stats.each do |i|
  #     stat[i] = stat[i]/num_games.to_f if num_games > 0
  #     totals["d#{i}"] = totals["d#{i}"]/num_games.to_f if num_games > 0
  #   end

  #   [stat,totals]
  # end














  # def calc_weighted_averages(date)
  #   #correct as of 2015/02/21
  #   year = self.year
  #   stats = ["or.m","or.a","fg.m","fg.a","three.m","three.a","ft.m","to.m","to.a"]
  #   totals = {}
  #   stats.each{|s| totals[s] = 0}
  #   wins, losses, opp_wins, opp_losses, opp_opp_wins, opp_opp_losses = 0,0,0,0,0,0 ###
  #   alt_wins, alt_total, pure_wins, pure_total = 0,0,0,0
  #   srs = 0;pt_diff = 0;opp_avg_pt_diff = 0
  #   stat = {}
  #   stats.each{|i| stat[i] = 0}
  #   num_games = 0
  #   games.each do |k,game|
  #     next unless game.date < date

  #     stats.each do |s| 
  #       totals[s] += game.stats(s)
  #     end
  #     totals["or.p"] = totals["or.m"]/totals["or.a"].to_f
  #     totals["efg.p"] = ((totals["fg.m"] + 0.5*totals["three.m"])/totals["fg.a"].to_f).to_N(3)
  #     totals["ftmr.p"] = (totals["ft.m"]/totals["fg.a"].to_f).to_N(3)
  #     totals["to.p"] = totals["to.m"]/totals["to.a"].to_f
      
  #     ratio = {}
  #     stats.each{|i| ratio[i] = $neutral_ratio_by_year[year][i][game.loc]}
  #     opp = Team.findteam("#{year} #{game.opp}")
  #     opp_sum = {}
  #     stats.each{|i| opp_sum[i] = 0}
  #     num_opp_games = 0
  #     num_games += 1
  #     pure_total += 1
  #     pure_wins += 1 if game.pts > game.opp_pts
  #     if game.pts > game.opp_pts
  #       wins += 1.4 if game.loc == "away"
  #       wins += 0.6 if game.loc == "home"
  #     elsif game.pts < game.opp_pts
  #       losses += 0.6 if game.loc == "away"
  #       losses += 1.4 if game.loc == "home"
  #     end
  #     pt_diff += game.pts - game.opp_pts
  #     opp_alt_wins,opp_alt_total = 0,0
  #     opp_pt_diff = 0
  #     opp.games.each do |index,opp_game|
  #       next unless opp_game.date < date
  #       next if opp_game.opp == self.code
  #       opp_ratio = {}
  #       stats.each{|i| opp_ratio[i] = $neutral_ratio_by_year[year][i][opp_game.opp_loc]}
        
  #       opp_opp = Team.findteam("#{year} #{opp_game.opp}")
  #       opp_opp_sum = {}
  #       stats.each{|i| opp_opp_sum[i] = 0}
  #       num_opp_opp_games = 0
  #       num_opp_games += 1
  #       opp_wins   += 1 if opp_game.pts > opp_game.opp_pts
  #       opp_losses += 1 if opp_game.pts < opp_game.opp_pts
  #       opp_pt_diff += opp_game.pts - opp_game.opp_pts
  #       opp_opp_alt_wins,opp_opp_alt_total = 0,0
  #       opp_opp_pts_diff = 0
  #       opp_opp.games.each do |index2,opp_opp_game|
  #         next unless opp_opp_game.date < date
  #         next if opp_opp_game.opp == self.code #skip games against the team in question
  #         num_opp_opp_games += 1
  #         opp_opp_wins += 1 if opp_opp_game.pts > opp_opp_game.opp_pts
  #         opp_opp_losses += 1 if opp_opp_game.pts < opp_opp_game.opp_pts
  #         opp_opp_ratio = {}
  #         stats.each{|i| opp_opp_ratio[i] = $neutral_ratio_by_year[year][i][opp_opp_game.loc]}
  #         stats.each{|i| opp_opp_sum[i] += opp_opp_game.stats(i)*opp_opp_ratio[i]/$neutral_averages_by_year[year][i]}
          
  #         opp_opp_alt_wins += $ratio_win_by_year[year][opp_opp_game.loc] if opp_opp_game.pts > opp_opp_game.opp_pts
  #         opp_opp_alt_total += $ratio_win_by_year[year][opp_opp_game.loc]
  #       end
  #       stats.each do |i|
  #         if (num_opp_opp_games > 0 and opp_opp_sum[i] > 0)
  #           opp_sum[i] += (opp_game.stats("d#{i}")*opp_ratio[i]/$neutral_averages_by_year[year][i])/(opp_opp_sum[i]/num_opp_opp_games.to_f) 
  #         else
  #           opp_sum[i] += opp_game.stats("d#{i}")*opp_ratio[i]/$neutral_averages_by_year[year][i] #if opp_opp exists, but hasn't played any other games
  #         end
  #       end
  #       if opp_opp_alt_wins > 0
  #         opp_alt_wins += $ratio_win_by_year[year][opp_game.loc]/(opp_opp_alt_wins/(0.5*opp_opp_alt_total.to_f)) if opp_game.pts > opp_game.opp_pts
  #         opp_alt_total += $ratio_win_by_year[year][opp_game.loc]/(opp_opp_alt_wins/(0.5*opp_opp_alt_total.to_f))
  #       else
  #         opp_alt_wins += $ratio_win_by_year[year][opp_game.loc] if opp_game.pts > opp_game.opp_pts
  #         opp_alt_total += $ratio_win_by_year[year][opp_game.loc]
  #       end
  #     end
  #     opp_avg_pt_diff += opp_pt_diff/num_opp_games.to_f###
      
  #     stats.each do |i|
  #       if (num_opp_games > 0 and opp_sum[i] > 0)
  #         stat[i] += game.stats(i)*ratio[i]/(opp_sum[i]/num_opp_games.to_f) 
  #       else
  #         stat[i] += game.stats(i)*ratio[i] #only when the opp exists, but hasn't played a game yet
  #       end
  #     end
  #     if opp_alt_wins > 0
  #       alt_wins += $ratio_win_by_year[year][game.loc]/(opp_alt_wins/(0.5*opp_alt_total.to_f)) if game.pts > game.opp_pts
  #       alt_total += $ratio_win_by_year[year][game.loc]/(opp_alt_wins/(0.5*opp_alt_total.to_f))
  #     else
  #       alt_wins += $ratio_win_by_year[year][game.loc] if game.pts > game.opp_pts
  #       alt_total += $ratio_win_by_year[year][game.loc]
  #     end
  #   end

  #   rpi = 0.25*(wins/(wins+losses).to_f) + 0.5*(opp_wins/(opp_wins+opp_losses).to_f) + 0.25*(opp_opp_wins/(opp_opp_wins + opp_opp_losses).to_f)###
  #   srs = (pt_diff + opp_avg_pt_diff)/num_games.to_f
  #   sos = opp_avg_pt_diff/num_games.to_f

  #   stats.each do |i|
  #     stat[i] = stat[i]/num_games.to_f if num_games > 0
  #   end
  #   stat["or.p"] = stat["or.m"]/stat["or.a"].to_f
  #   stat["efg.p"] = (stat["fg.m"]+0.5*stat["three.m"])/stat["fg.a"].to_f
  #   stat["ftmr.p"] = stat["ft.m"]/stat["fg.a"].to_f
  #   stat["to.p"] = stat["to.m"]/stat["to.a"].to_f

  #   [stat,totals,rpi,srs,sos,pure_wins/pure_total.to_f,alt_wins/alt_total.to_f]
  # end

  # def calc_opp_weighted_averages(date)
  #   #correct as of 2015/02/21
  #   year = self.year
  #   stats = ["or.m","or.a","fg.m","fg.a","three.m","three.a","ft.m","to.m","to.a"]
  #   totals = {}
  #   stats.each{|s| totals["d#{s}"] = 0}
  #   stat = {}
  #   stats.each{|i| stat[i] = 0}
  #   num_games = 0
  #   games.each do |k,game|
  #     next unless game.date < date

  #     stats.each do |s| 
  #       totals["d#{s}"] += game.stats("d#{s}")
  #     end
  #     totals["or.p"] = totals["dor.m"]/totals["dor.a"].to_f
  #     totals["efg.p"] = ((totals["dfg.m"] + 0.5*totals["dthree.m"])/totals["dfg.a"].to_f).to_N(3)
  #     totals["ftmr.p"] = (totals["dft.m"]/totals["dfg.a"].to_f).to_N(3)
  #     totals["to.p"] = totals["dto.m"]/totals["dto.a"].to_f

  #     ratio = {}
  #     stats.each{|i| ratio[i] = $neutral_ratio_by_year[year][i][game.loc]}
  #     opp = Team.findteam("#{year} #{game.opp}")
  #     opp_sum = {}
  #     stats.each{|i| opp_sum[i] = 0}
  #     num_opp_games = 0
  #     num_games += 1
  #     opp.games.each do |index,opp_game|
  #       next unless opp_game.date < date
  #       next if opp_game.opp == self.code
  #       opp_ratio = {}
  #       stats.each{|i| opp_ratio[i] = $neutral_ratio_by_year[year][i][opp_game.opp_loc]}
        
  #       opp_opp = Team.findteam("#{year} #{opp_game.opp}")
  #       opp_opp_sum = {}
  #       stats.each{|i| opp_opp_sum[i] = 0}
  #       num_opp_opp_games = 0
  #       num_opp_games += 1
  #       opp_opp.games.each do |index2,opp_opp_game|
  #         next unless opp_opp_game.date < date
  #         next if opp_opp_game.opp == self.code #skip games against the team in question
  #         num_opp_opp_games += 1
  #         opp_opp_ratio = {}
  #         stats.each{|i| opp_opp_ratio[i] = $neutral_ratio_by_year[year][i][opp_opp_game.loc]}
  #         stats.each{|i| opp_opp_sum[i] += opp_opp_game.stats("d#{i}")*opp_opp_ratio[i]/$neutral_averages_by_year[year][i]}
  #       end
  #       stats.each do |i|
  #         if (num_opp_opp_games > 0 and opp_opp_sum[i] > 0)
  #           opp_sum[i] += (opp_game.stats(i)*opp_ratio[i]/$neutral_averages_by_year[year][i])/(opp_opp_sum[i]/num_opp_opp_games.to_f) 
  #         else
  #           opp_sum[i] += opp_game.stats(i)*opp_ratio[i]/$neutral_averages_by_year[year][i] #if opp_opp exists, but hasn't played any other games
  #         end
  #       end
  #     end
      
  #     stats.each do |i|
  #       if (num_opp_games > 0 and opp_sum[i] > 0)
  #         stat[i] += game.stats("d#{i}")*ratio[i]/(opp_sum[i]/num_opp_games.to_f) 
  #       else
  #         stat[i] += game.stats("d#{i}")*ratio[i] #only when the opp exists, but hasn't played a game yet
  #       end
  #     end
  #   end

  #   stats.each do |i|
  #     stat[i] = stat[i]/num_games.to_f if num_games > 0
  #   end
  #   stat["or.p"] = stat["or.m"]/stat["or.a"].to_f
  #   stat["efg.p"] = (stat["fg.m"]+0.5*stat["three.m"])/stat["fg.a"].to_f
  #   stat["ftmr.p"] = stat["ft.m"]/stat["fg.a"].to_f
  #   stat["to.p"] = stat["to.m"]/stat["to.a"].to_f
  #   [stat,totals]
  # end







