class Player
  def distance(this_season,num_to_use = 100)
    stats = []
    index = @seasons.index(this_season)
    last_season = @seasons[index - 1]
    stats[0] = index ###years in the league before this season
    stats[1] = last_season.g
    stats[2] = last_season.mp/last_season.g.to_f
    stats[3] = last_season.twoa/last_season.mp.to_f
    stats[4] = last_season.twop
    stats[5] = last_season.threea/last_season.mp.to_f
    stats[6] = last_season.threep

    g = 0;mp = 0;twom = 0;twoa = 0;threem = 0;threea = 0
    @seasons.each_with_index do |season,ind|
      next if ind >= index ##only look at his career before this_year
      g += season.g
      mp += season.mp
      twom += season.twom
      twoa += season.twoa
      threem += season.threem
      threea += season.threea
    end

    stats[7] = g
    stats[8] = mp/g.to_f
    stats[9] = twoa/mp.to_f
    stats[10] = twom/twoa.to_f
    stats[11] = threea/mp.to_f
    stats[12] = threem/threea.to_f

    #puts "#{@name}\t#{stats[0]}\t#{stats[1]}\t#{stats[2]}\t#{stats[3]}\t#{stats[4]}\t#{stats[5]}\t#{stats[6]}"

    closest = Hash.new
    Player.each do |player|
      skip_year = nil
      g = 0;mp = 0;twom = 0;twoa = 0;threem = 0;threea = 0
      player.seasons.each_with_index do |season,ind|
        next if season.year == skip_year
        if season.team == "TOT"
          skip_year = season.year
        end
        next if ind == 0
        next if season == this_season
        next if season == last_season
        next if season.year < 1994
        next if season.year >= this_season.year
        next if season.mp < 100
        next if season.threea/season.mp.to_f < 0.01

        next_season = player.season(season.year + 1)
        next if next_season.nil?
        next if next_season.mp < 100
        next if next_season.threea/next_season.mp.to_f < 0.01

        new_stats = []
        new_stats[0] = ind
        new_stats[1] = season.g
        new_stats[2] = season.mp/season.g.to_f
        new_stats[3] = season.twoa/season.mp.to_f
        new_stats[4] = season.twop
        new_stats[5] = season.threea/season.mp.to_f
        new_stats[6] = season.threep

        new_stats[7] = g
        new_stats[8] = mp/g.to_f
        new_stats[9] = twoa/mp.to_f
        new_stats[10] = twom/twoa.to_f
        new_stats[11] = threea/mp.to_f
        new_stats[12] = threem/threea.to_f

        g += season.g
        mp += season.mp
        twom += season.twom
        twoa += season.twoa
        threem += season.threem
        threea += season.threea

        distance = 0
        #for i in 0..6
        [1,3,5,6,11,12].each do |i|
          distance += $weights[i]*((new_stats[i] - stats[i])/$std_devs[i])**2
        end

        next if distance.nan?

        if distance == 0
          puts "hey 0 distance"
        end
        
        if closest.length < num_to_use
          closest["#{player.name}\t#{ind}"] = distance
        else
          max_key = get_max(closest)
          if distance < closest[max_key]
            closest.delete(max_key)
            closest["#{player.name}\t#{ind}"] = distance
          end
        end
      end
    end
    
    #puts "max distance  = #{closest[get_max(closest)]}"
    
    threeps = []
    closest.each_pair do |key,val|
      name,season_ind = *key.split("\t")
      that_season = Player.findplayer(name).seasons[season_ind.to_i]
      next_season = nil
      next_season = Player.findplayer(name).season(that_season.year + 1)
      threeps.push next_season.threep unless next_season.nil?
      #puts "#{name}\t#{season_ind}\t#{that_season.year}\t#{that_season.g}\t#{that_season.mp/that_season.g.to_f}\t#{that_season.twoa/that_season.mp.to_f}\t#{that_season.twop}\t#{that_season.threea/that_season.mp.to_f}\t#{that_season.threep}\t\t#{next_season.threep}" unless next_season.nil?
    end

    #puts "#{threeps.average}\t#{threeps.std_dev}"
    #puts "#{this_season.threep}"
    #puts
    [threeps.average,threeps.std_dev]
  end

  def distance_new(stat,this_season,num_to_use = 100)
    stats = []
    index = @seasons.index(this_season)
    last_season = @seasons[index - 1]
    which_stats = ["mp","#{stat}a","#{stat}p"]

    stats[0] = last_season.stats("mp")/(last_season.stats("g")*48).to_f
    stats[1] = last_season.stats("#{stat}a")/last_season.stats("mp").to_f
    stats[2] = last_season.stats("#{stat}p")

    mp = 0; statm = 0; stata = 0
    @seasons.each_with_index do |season,ind|
      next if ind >= index ##only look at his career before this_year
      mp += season.stats("mp")
      statm += season.stats("#{stat}m")
      stata += season.stats("#{stat}a")
    end

    #stats[3] = mp
    #stats[4] = stata
    #stats[5] = statm/stata.to_f

    #puts "#{@name}\t#{last_season.year}\t#{stats[0]}\t#{stats[1]}\t#{stats[2]}"
    #puts

    closest = Hash.new
    Player.each do |player|
      skip_year = nil
      mp2 = 0; statm2 = 0; stata2 = 0
      player.seasons.each_with_index do |season,ind|
        next if season.year == skip_year
        if season.team == "TOT"##skip the partial seasons that make up the total
          skip_year = season.year
        end
        next if ind == 0 #skip rookie seasons
        next if season == this_season
        next if season == last_season
        next if season.year < this_season.year - 5   ##search the last 5 seasons
        next if season.year >= this_season.year
        next if season.year < 1985
        next if season.stats("mp") < 100
        next if season.stats("#{stat}a")/season.stats("mp").to_f < 0.01

        ##get rid of guys who don't play the next year or don't play much
        next_season = player.season(season.year + 1)
        next if next_season.nil?
        next if next_season.stats("mp") < 100
        next if next_season.stats("#{stat}a")/next_season.stats("mp").to_f < 0.01

        new_stats = []
        new_stats[0] = season.stats("mp")/(season.stats("g")*48).to_f
        new_stats[1] = season.stats("#{stat}a")/season.stats("mp")
        new_stats[2] = season.stats("#{stat}p")

        #new_stats[3] = mp2
        #new_stats[4] = stata2
        #new_stats[5] = statm/stata.to_f

        mp2 += season.stats("mp")
        statm2 += season.stats("#{stat}m")
        stata2 += season.stats("#{stat}a")

        distance = 0
        which_stats.each_with_index do |ss,i|
          ##note we're using the mean and total standard deviation from the year in question, not the 5-year ones
          # puts
          # puts "#{ss}\t#{i}"
          # puts stats[i]
          # puts new_stats[i]
          # puts season.year
          # puts $mean_and_dev[ss][season.year][4]
          # puts $mean_and_dev[ss][season.year][5]
          # puts $mean_and_dev[ss][last_season.year][4]
          # puts $mean_and_dev[ss][last_season.year][5]
          distance += $weights2[i]*((new_stats[i] - $mean_and_dev[ss][season.year][4])/$mean_and_dev[ss][season.year][5] -
                                    (stats[i] - $mean_and_dev[ss][last_season.year][4])/$mean_and_dev[ss][last_season.year][5])**2
          # puts distance
        end

        next if distance.nan?

        if distance == 0
          puts "hey 0 distance"
        end
        
        if closest.length < num_to_use
          closest["#{player.name}\t#{ind}"] = distance
        else
          max_key = get_max(closest)
          if distance < closest[max_key]
            closest.delete(max_key)
            closest["#{player.name}\t#{ind}"] = distance
          end
        end
      end
    end
    
    #puts "max distance  = #{closest[get_max(closest)]}"
    
    next_season_stats = []
    pcts = Pcts.new
    closest.each_pair do |key,val|
      name,season_ind = *key.split("\t")
      that_season = Player.findplayer(name).seasons[season_ind.to_i]
      next_season = nil
      next_season = Player.findplayer(name).season(that_season.year+1) unless that_season.nil?
      unless next_season.nil?
        next_season_stats.push next_season.stats("#{stat}p") 
        pcts.add_pct(Pct.new(next_season.stats("#{stat}m"),next_season.stats("#{stat}a"))) if (next_season.stats("#{stat}m") > 0 and next_season.stats("#{stat}m") != next_season.stats("#{stat}a"))
        #puts "#{name}\t#{that_season.year}\t#{that_season.stats("mp")/(that_season.stats("g")*48).to_f}\t#{that_season.stats("#{stat}a")/that_season.stats("mp")}\t#{that_season.stats("#{stat}p")}\t\t#{next_season.stats("#{stat}p")}"
      end
    end

    pcts_p = pcts.p_bar
    pcts_rand_err = Math::sqrt(pcts.sum_indiv_vars)
    pcts_std_dev = pcts.weighted_std_dev
    skill_std_dev = Math::sqrt(pcts_std_dev**2 - pcts_rand_err**2)

    if pcts_p.nan?
      puts "ERROR:\t#{pcts.sum("m")}\t#{pcts.sum("a")}"
    end
    if skill_std_dev.nan?
      puts "#{self.name}\t#{pcts_p}\t#{pcts_rand_err}\t#{pcts_std_dev}\t#{skill_std_dev}"
      exit
    end
    #puts "#{next_season_stats.average}\t#{next_season_stats.std_dev}"
    #puts "#{pcts_p}\t#{skill_std_dev}"
    #puts "#{this_season.stats("#{stat}p")}"
    #puts
    [next_season_stats.average,next_season_stats.std_dev,pcts_p,skill_std_dev]
  end
  
end
