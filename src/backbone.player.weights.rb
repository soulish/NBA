class Player

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

  def calc_weighted_averages(date,year)
    #correct as of 2015/02/25
    stats = ["pts","mp","fg.a","fg.p","two.a","two.p","three.a","three.p","ft.a","ft.p",
             "or.m","or.p","dr.m","dr.p","tr.m","tr.p","as.m","as.p","st.m","st.p","bl.m","bl.p","to.m","to.p"]
    totals = {};    stats.each{|s| totals[s] = 0}
    stat = {};      stats.each{|i| stat[i] = 0}
    num_games = 0
    games_by_season[year].each do |game|
      next unless game.date < date
      stats.each{|s| totals[s] += game.stats(s)}
      
      opp = Team.findteam("#{year} #{game.opp}")
      opp_waverage = opp.waverages[date]

      num_games += 1
      
      stats.each do |i|
        next if i == "mp"
        if (opp_waverage.nil? or opp_waverage.stats("d#{i}").nil?)
          #puts "Skipping #{year} #{game.opp}\t#{date}"
          stat[i] += game.stats(i)*$neutral_ratio_by_year[year][i][game.loc] #only when the opp exists, but hasn't played a game yet
        else
          stat[i] += game.stats(i)*$neutral_ratio_by_year[year][i][game.loc]*$team_5yr_averages[year][i][0]/(opp_waverage.stats("d#{i}")/opp_waverage.num_games.to_f) unless i.include?(".p")
          stat[i] += game.stats(i)*$neutral_ratio_by_year[year][i][game.loc]*$team_5yr_averages[year][i][0]/opp_waverage.stats("d#{i}") if i.include?(".p")
        end
      end
    end

    stats.each do |i|
      next unless i.include?(".p")
      stat[i] = stat[i]/num_games.to_f if num_games > 0
      totals[i] = totals[i]/num_games.to_f if num_games > 0
    end
    
    stat["mp"] = totals["mp"] #There is no weighting for mp
    stat["as.m"] = totals["as.m"] #Weighting for assists is messed up
    [stat,totals,num_games]
  end
end
