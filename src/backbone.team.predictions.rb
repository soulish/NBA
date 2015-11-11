class Team
  def predict_wp_distance(num_to_use = 10)
    main_stats = []
    last_years_main_team = Team.findteam("#{self.psname}")
    last_years_main_wp = last_years_main_team.pct
    last_years_main_std_dev = Math::sqrt(last_years_main_team.pct*(1-last_years_main_team.pct)/(last_years_main_team.wins + last_years_main_team.losses).to_f)
    last_season_main = last_years_main_team.season
    which_stats = ["or.p","efg.p","ftmr.p","to.p","dor.p","defg.p","dftmr.p","dto.p","wp.p"]

    which_stats.each_with_index do |s,i|
      main_stats[i] = last_season_main.stats(s)
    end

    #puts "#{self.codeyear}\t\t#{last_years_main_wp.to_n(3)}\t#{main_stats[0].to_n(3)}\t#{main_stats[1].to_n(3)}\t#{main_stats[2].to_n(3)}\t#{main_stats[3].to_n(3)}\t#{main_stats[4].to_n(3)}\t#{main_stats[5].to_n(3)}\t#{main_stats[6].to_n(3)}\t#{main_stats[7].to_n(3)}\t"

    closest = Hash.new
    Team.each do |test_team|
      test_season = test_team.season
      next if test_season == last_season_main
      next if test_season.year >= self.year
      next if test_season.year < 1986

      next_years_test_team = Team.findteam("#{test_team.nsname}")
      next if next_years_test_team.nil?
      next_season_test = next_years_test_team.season
      next if next_season_test.nil?

      #next unless test_season.pct.in_between(last_years_main_wp - last_years_main_std_dev,
      #                                  last_years_main_wp + last_years_main_std_dev)

      new_stats = []
      which_stats.each_with_index do |s,i|
        new_stats[i] = test_season.stats(s)
      end

      distance = 0
      which_stats.each_with_index do |ss,i|
        distance += $weights_team[ss]*((new_stats[i] - $team_mean_and_dev[ss][test_season.year][0])/$team_mean_and_dev[ss][test_season.year][1] -
                                       (main_stats[i] - $team_mean_and_dev[ss][last_season_main.year][0])/$team_mean_and_dev[ss][last_season_main.year][1])**2
        # puts distance
      end
      
      next if distance.nan?
      
      if distance == 0
        puts "hey 0 distance"
      end
        
      if closest.length < num_to_use
        closest[test_team.codeyear] = distance
      else
        max_key = get_max(closest)
        if distance < closest[max_key]
          closest.delete(max_key)
          closest[test_team.codeyear] = distance
        end
      end
    end
    
    #puts "max distance  = #{closest[get_max(closest)]}"
    
    next_season_stats = []
    pcts = Pcts.new
    closest.each_pair do |key,val|
      that_team = Team.findteam(key)
      that_season = that_team.season
      next_season = nil
      next_season = Team.findteam("#{that_team.nsname}").season unless that_season.nil?
      unless next_season.nil?
        next_season_stats.push next_season.pct
        pcts.add_pct(Pct.new(next_season.wins,next_season.wins + next_season.losses))

        #puts "#{that_team.codeyear}\t\t#{that_season.pct.to_n(3)}\t#{that_season.stats(which_stats[0)].to_n(3)}\t#{that_season.stats(which_stats[1)].to_n(3)}\t#{that_season.stats(which_stats[2)].to_n(3)}\t#{that_season.stats(which_stats[3)].to_n(3)}\t#{that_season.stats(which_stats[4)].to_n(3)}\t#{that_season.stats(which_stats[5)].to_n(3)}\t#{that_season.stats(which_stats[6)].to_n(3)}\t#{that_season.stats(which_stats[7)].to_n(3)}\t"
      end
    end
    #puts closest.length

    pcts_p = pcts.p_bar
    pcts_std_dev = pcts.weighted_std_dev

    if pcts_p.nan?
      #puts "ERROR:\t#{pcts.sum("m")}\t#{pcts.sum("a")}"
    end
    #puts "#{next_season_stats.average}\t#{next_season_stats.std_dev}"
    #puts "#{pcts_p}\t#{pcts_std_dev}"
    #puts "#{this_season.stats("#{stat}p")}"
    #puts
    #[next_season_stats.average,next_season_stats.std_dev,pcts_p,pcts_std_dev]
    [pcts_p,pcts_std_dev]
  end
  alias_method :distance_new, :predict_wp_distance

  def predict_wp_distance2(num_to_use = 100)
    main_stats = []
    which_stats = ["roster_or.p","roster_efg.p","roster_ftmr.p","roster_to.p","roster_wsp48.p"]
    main_season = self.season
    which_stats.each_with_index do |s,i|
      main_stats[i] = main_season.stats(s)
    end

    #puts "#{self.codeyear}\t\tt#{main_stats[0].to_n(3)}\t#{main_stats[1].to_n(3)}\t#{main_stats[2].to_n(3)}\t#{main_stats[3].to_n(3)}\t#{main_stats[4].to_n(3)}\t#{main_stats[5].to_n(3)}\t#{main_stats[6].to_n(3)}\t#{main_stats[7].to_n(3)}\t"

    closest = Hash.new
    Team.each do |test_team|
      test_season = test_team.season
      next if test_season.year >= self.year
      next if test_season.year < 1986

      new_stats = []
      which_stats.each_with_index do |s,i|
        new_stats[i] = test_season.stats(s)
      end

      distance = 0
      which_stats.each_with_index do |ss,i|
        distance += $weights_team2[ss]*((new_stats[i] - $team_mean_and_dev[ss][test_season.year][0])/$team_mean_and_dev[ss][test_season.year][1] -
                                        (main_stats[i] - $team_mean_and_dev[ss][main_season.year][0])/$team_mean_and_dev[ss][main_season.year][1])**2
        # puts distance
      end
      
      next if distance.nan?
      
      if distance == 0
        puts "hey 0 distance"
      end
        
      if closest.length < num_to_use
        closest[test_team.codeyear] = distance
      else
        max_key = get_max(closest)
        if distance < closest[max_key]
          closest.delete(max_key)
          closest[test_team.codeyear] = distance
        end
      end
    end
    
    #puts "max distance  = #{closest[get_max(closest)]}"
    
    that_season_stats = []
    pcts = Pcts.new
    closest.each_pair do |key,val|
      that_team = Team.findteam(key)
      that_season = that_team.season
      that_season_stats.push that_season.pct
      pcts.add_pct(Pct.new(that_season.wins,that_season.wins + that_season.losses))

      #puts "#{that_team.codeyear}\t\t#{that_season.pct.to_n(3)}\t#{that_season.stats(which_stats[0)].to_n(3)}\t#{that_season.stats(which_stats[1)].to_n(3)}\t#{that_season.stats(which_stats[2)].to_n(3)}\t#{that_season.stats(which_stats[3)].to_n(3)}\t#{that_season.stats(which_stats[4)].to_n(3)}\t#{that_season.stats(which_stats[5)].to_n(3)}\t#{that_season.stats(which_stats[6)].to_n(3)}\t#{that_season.stats(which_stats[7)].to_n(3)}\t"
    end
    #puts closest.length

    pcts_p = pcts.p_bar
    pcts_std_dev = pcts.weighted_std_dev

    if pcts_p.nan?
      #puts "ERROR:\t#{pcts.sum("m")}\t#{pcts.sum("a")}"
    end
    #puts "#{next_season_stats.average}\t#{next_season_stats.std_dev}"
    #puts "#{pcts_p}\t#{pcts_std_dev}"
    #puts "#{this_season.stats("#{stat}p")}"
    #puts
    #[next_season_stats.average,next_season_stats.std_dev,pcts_p,pcts_std_dev]
    [pcts_p,pcts_std_dev]
  end
  alias_method :distance2, :predict_wp_distance2

  def predict_wp_distance_combined(num_to_use = 100)
    main_stats = []
    last_years_main_team = Team.findteam("#{self.psname}")
    last_years_main_wp = last_years_main_team.pct
    last_years_main_std_dev = Math::sqrt(last_years_main_team.pct*(1-last_years_main_team.pct)/(last_years_main_team.wins + last_years_main_team.losses).to_f)
    last_season_main = last_years_main_team.season
    main_season = self.season

    which_stats = ["or.p","efg.p","ftmr.p","to.p","dor.p","defg.p","dftmr.p","dto.p","wp.p",
                   "roster_or.p","roster_efg.p","roster_ftmr.p","roster_to.p","roster_wsp48.p"]

    which_stats.each_with_index do |s,i|
      main_stats[i] = last_season_main.stats(s) if !s.include?("roster")
      main_stats[i] = main_season.stats(s) if s.include?("roster")
    end

    #puts "#{self.codeyear}\t\t#{last_years_main_wp.to_n(3)}\t#{main_stats[0].to_n(3)}\t#{main_stats[1].to_n(3)}\t#{main_stats[2].to_n(3)}\t#{main_stats[3].to_n(3)}\t#{main_stats[4].to_n(3)}\t#{main_stats[5].to_n(3)}\t#{main_stats[6].to_n(3)}\t#{main_stats[7].to_n(3)}\t#{main_stats[8].to_n(3)}\t#{main_stats[9].to_n(3)}\t#{main_stats[10].to_n(3)}\t#{main_stats[11].to_n(3)}\t#{main_stats[12].to_n(3)}\t#{main_stats[13].to_n(3)}"

    closest = Hash.new
    Team.each do |test_team|
      test_season = test_team.season
      next if test_season == last_season_main
      #can't look at the current or previous years because we require end of season and beginning of next season
      next if test_season.year >= self.year - 1
      next if test_season.year < 1986

      next_years_test_team = Team.findteam("#{test_team.nsname}")
      next if next_years_test_team.nil?
      next_season_test = next_years_test_team.season
      next if next_season_test.nil?

      #next unless test_season.pct.in_between(last_years_main_wp - last_years_main_std_dev,
      #                                  last_years_main_wp + last_years_main_std_dev)

      new_stats = []
      which_stats.each_with_index do |s,i|
        new_stats[i] = test_season.stats(s) if !s.include?("roster")
        new_stats[i] = next_season_test.stats(s) if s.include?("roster")
      end

      distance = 0
      which_stats.each_with_index do |ss,i|
        #puts "#{i}\t#{$weights_team3[i]}"
        distance += $weights_team3[ss]*((new_stats[i] - $team_mean_and_dev[ss][test_season.year][0])/$team_mean_and_dev[ss][test_season.year][1] -
                                       (main_stats[i] - $team_mean_and_dev[ss][last_season_main.year][0])/$team_mean_and_dev[ss][last_season_main.year][1])**2 if !ss.include?("roster")
        distance += $weights_team3[ss]*((new_stats[i] - $team_mean_and_dev[ss][next_season_test.year][0])/$team_mean_and_dev[ss][next_season_test.year][1] -
                                       (main_stats[i] - $team_mean_and_dev[ss][main_season.year][0])/$team_mean_and_dev[ss][main_season.year][1])**2 if ss.include?("roster")
        # puts distance
      end
      
      next if distance.nan?
      
      if distance == 0
        puts "hey 0 distance"
      end
        
      if closest.length < num_to_use
        closest[test_team.codeyear] = distance
      else
        max_key = get_max(closest)
        if distance < closest[max_key]
          closest.delete(max_key)
          closest[test_team.codeyear] = distance
        end
      end
    end
    
    #puts "max distance  = #{closest[get_max(closest)]}"
    
    next_season_stats = []
    pcts = Pcts.new
    closest.each_pair do |key,val|
      that_team = Team.findteam(key)
      that_season = that_team.season
      next_season = nil
      next_season = Team.findteam("#{that_team.nsname}").season unless that_season.nil?
      unless next_season.nil?
        next_season_stats.push next_season.pct
        pcts.add_pct(Pct.new(next_season.wins,next_season.wins + next_season.losses))

        #puts "#{that_team.codeyear}\t\t#{that_season.pct.to_n(3)}\t#{that_season.stats(which_stats[0]).to_n(3)}\t#{that_season.stats(which_stats[1]).to_n(3)}\t#{that_season.stats(which_stats[2]).to_n(3)}\t#{that_season.stats(which_stats[3]).to_n(3)}\t#{that_season.stats(which_stats[4]).to_n(3)}\t#{that_season.stats(which_stats[5]).to_n(3)}\t#{that_season.stats(which_stats[6]).to_n(3)}\t#{that_season.stats(which_stats[7]).to_n(3)}\t#{that_season.stats(which_stats[8]).to_n(3)}\t#{that_season.stats(which_stats[9]).to_n(3)}\t#{that_season.stats(which_stats[10]).to_n(3)}\t#{that_season.stats(which_stats[11]).to_n(3)}\t#{that_season.stats(which_stats[12]).to_n(3)}\t#{that_season.stats(which_stats[13]).to_n(3)}\t\t#{next_season.pct.to_n(3)}"
      end
    end
    #puts closest.length

    pcts_p = pcts.p_bar
    pcts_std_dev = pcts.weighted_std_dev

    if pcts_p.nan?
      #puts "ERROR:\t#{pcts.sum("m")}\t#{pcts.sum("a")}"
    end
    #puts "#{next_season_stats.average}\t#{next_season_stats.std_dev}"
    #puts "#{pcts_p}\t#{pcts_std_dev}"
    #puts "#{this_season.stats("#{stat}p")}"
    #puts
    #[next_season_stats.average,next_season_stats.std_dev,pcts_p,pcts_std_dev]
    [pcts_p,pcts_std_dev]
  end

  def predict_wp_distance_ws(num_to_use = 100)
    main_stats = []
    which_stats = ["roster_wsp48.p"]
    main_season = self.season
    which_stats.each_with_index do |s,i|
      main_stats[i] = main_season.stats(s)
    end

    #puts "#{self.codeyear}\t\tt#{main_stats[0].to_n(3)}\t#{main_stats[1].to_n(3)}\t#{main_stats[2].to_n(3)}\t#{main_stats[3].to_n(3)}\t#{main_stats[4].to_n(3)}\t#{main_stats[5].to_n(3)}\t#{main_stats[6].to_n(3)}\t#{main_stats[7].to_n(3)}\t"

    closest = Hash.new
    Team.each do |test_team|
      test_season = test_team.season
      next if test_season.year >= self.year
      next if test_season.year < 1986

      new_stats = []
      which_stats.each_with_index do |s,i|
        new_stats[i] = test_season.stats(s)
      end

      distance = 0
      which_stats.each_with_index do |ss,i|
        distance += $weights_team_ws[ss]*((new_stats[i] - $team_mean_and_dev[ss][test_season.year][0])/$team_mean_and_dev[ss][test_season.year][1] -
                                          (main_stats[i] - $team_mean_and_dev[ss][main_season.year][0])/$team_mean_and_dev[ss][main_season.year][1])**2
        # puts distance
      end
      
      next if distance.nan?
      
      if distance == 0
        puts "hey 0 distance"
      end
        
      if closest.length < num_to_use
        closest[test_team.codeyear] = distance
      else
        max_key = get_max(closest)
        if distance < closest[max_key]
          closest.delete(max_key)
          closest[test_team.codeyear] = distance
        end
      end
    end
    
    #puts "max distance  = #{closest[get_max(closest)]}"
    
    that_season_stats = []
    pcts = Pcts.new
    closest.each_pair do |key,val|
      that_team = Team.findteam(key)
      that_season = that_team.season
      that_season_stats.push that_season.pct
      pcts.add_pct(Pct.new(that_season.wins,that_season.wins + that_season.losses))

      #puts "#{that_team.codeyear}\t\t#{that_season.pct.to_n(3)}\t#{that_season.stats(which_stats[0)].to_n(3)}\t#{that_season.stats(which_stats[1)].to_n(3)}\t#{that_season.stats(which_stats[2)].to_n(3)}\t#{that_season.stats(which_stats[3)].to_n(3)}\t#{that_season.stats(which_stats[4)].to_n(3)}\t#{that_season.stats(which_stats[5)].to_n(3)}\t#{that_season.stats(which_stats[6)].to_n(3)}\t#{that_season.stats(which_stats[7)].to_n(3)}\t"
    end
    #puts closest.length

    pcts_p = pcts.p_bar
    pcts_std_dev = pcts.weighted_std_dev

    if pcts_p.nan?
      #puts "ERROR:\t#{pcts.sum("m")}\t#{pcts.sum("a")}"
    end
    #puts "#{next_season_stats.average}\t#{next_season_stats.std_dev}"
    #puts "#{pcts_p}\t#{pcts_std_dev}"
    #puts "#{this_season.stats("#{stat}p")}"
    #puts
    #[next_season_stats.average,next_season_stats.std_dev,pcts_p,pcts_std_dev]
    [pcts_p,pcts_std_dev]
  end

  def predict_wp_distance_ows(num_to_use = 100)
    main_stats = []
    which_stats = ["roster_owsp48.p","roster_dwsp48.p"]
    main_season = self.season
    which_stats.each_with_index do |s,i|
      main_stats[i] = main_season.stats(s)
    end

    #puts "#{self.codeyear}\t\tt#{main_stats[0].to_n(3)}\t#{main_stats[1].to_n(3)}\t#{main_stats[2].to_n(3)}\t#{main_stats[3].to_n(3)}\t#{main_stats[4].to_n(3)}\t#{main_stats[5].to_n(3)}\t#{main_stats[6].to_n(3)}\t#{main_stats[7].to_n(3)}\t"

    closest = Hash.new
    Team.each do |test_team|
      test_season = test_team.season
      next if test_season.year >= self.year
      next if test_season.year < 1986

      new_stats = []
      which_stats.each_with_index do |s,i|
        new_stats[i] = test_season.stats(s)
      end

      distance = 0
      which_stats.each_with_index do |ss,i|
        distance += $weights_team_ows[ss]*((new_stats[i] - $team_mean_and_dev[ss][test_season.year][0])/$team_mean_and_dev[ss][test_season.year][1] -
                                           (main_stats[i] - $team_mean_and_dev[ss][main_season.year][0])/$team_mean_and_dev[ss][main_season.year][1])**2
        # puts distance
      end
      
      next if distance.nan?
      
      if distance == 0
        puts "hey 0 distance"
      end
        
      if closest.length < num_to_use
        closest[test_team.codeyear] = distance
      else
        max_key = get_max(closest)
        if distance < closest[max_key]
          closest.delete(max_key)
          closest[test_team.codeyear] = distance
        end
      end
    end
    
    #puts "max distance  = #{closest[get_max(closest)]}"
    
    that_season_stats = []
    pcts = Pcts.new
    closest.each_pair do |key,val|
      that_team = Team.findteam(key)
      that_season = that_team.season
      that_season_stats.push that_season.pct
      pcts.add_pct(Pct.new(that_season.wins,that_season.wins + that_season.losses))

      #puts "#{that_team.codeyear}\t\t#{that_season.pct.to_n(3)}\t#{that_season.stats(which_stats[0)].to_n(3)}\t#{that_season.stats(which_stats[1)].to_n(3)}\t#{that_season.stats(which_stats[2)].to_n(3)}\t#{that_season.stats(which_stats[3)].to_n(3)}\t#{that_season.stats(which_stats[4)].to_n(3)}\t#{that_season.stats(which_stats[5)].to_n(3)}\t#{that_season.stats(which_stats[6)].to_n(3)}\t#{that_season.stats(which_stats[7)].to_n(3)}\t"
    end
    #puts closest.length

    pcts_p = pcts.p_bar
    pcts_std_dev = pcts.weighted_std_dev

    if pcts_p.nan?
      #puts "ERROR:\t#{pcts.sum("m")}\t#{pcts.sum("a")}"
    end
    #puts "#{next_season_stats.average}\t#{next_season_stats.std_dev}"
    #puts "#{pcts_p}\t#{pcts_std_dev}"
    #puts "#{this_season.stats("#{stat}p")}"
    #puts
    #[next_season_stats.average,next_season_stats.std_dev,pcts_p,pcts_std_dev]
    [pcts_p,pcts_std_dev]
  end

  def predict_wp_distance_gsp(num_to_use = 100)
    main_stats = []
    which_stats = ["roster_gsp.p"]
    main_season = self.season
    which_stats.each_with_index do |s,i|
      main_stats[i] = main_season.stats(s)
    end

    #puts "#{self.codeyear}\t\tt#{main_stats[0].to_n(3)}\t#{main_stats[1].to_n(3)}\t#{main_stats[2].to_n(3)}\t#{main_stats[3].to_n(3)}\t#{main_stats[4].to_n(3)}\t#{main_stats[5].to_n(3)}\t#{main_stats[6].to_n(3)}\t#{main_stats[7].to_n(3)}\t"

    closest = Hash.new
    Team.each do |test_team|
      test_season = test_team.season
      next if test_season.year >= self.year
      next if test_season.year < 1986

      new_stats = []
      which_stats.each_with_index do |s,i|
        new_stats[i] = test_season.stats(s)
      end

      distance = 0
      which_stats.each_with_index do |ss,i|
        distance += $weights_team_gsp[ss]*((new_stats[i] - $team_mean_and_dev[ss][test_season.year][0])/$team_mean_and_dev[ss][test_season.year][1] -
                                           (main_stats[i] - $team_mean_and_dev[ss][main_season.year][0])/$team_mean_and_dev[ss][main_season.year][1])**2
        # puts distance
      end
      
      next if distance.nan?
      
      if distance == 0
        puts "hey 0 distance"
      end
        
      if closest.length < num_to_use
        closest[test_team.codeyear] = distance
      else
        max_key = get_max(closest)
        if distance < closest[max_key]
          closest.delete(max_key)
          closest[test_team.codeyear] = distance
        end
      end
    end
    
    #puts "max distance  = #{closest[get_max(closest)]}"
    
    that_season_stats = []
    pcts = Pcts.new
    closest.each_pair do |key,val|
      that_team = Team.findteam(key)
      that_season = that_team.season
      that_season_stats.push that_season.pct
      pcts.add_pct(Pct.new(that_season.wins,that_season.wins + that_season.losses))

      #puts "#{that_team.codeyear}\t\t#{that_season.pct.to_n(3)}\t#{that_season.stats(which_stats[0)].to_n(3)}\t#{that_season.stats(which_stats[1)].to_n(3)}\t#{that_season.stats(which_stats[2)].to_n(3)}\t#{that_season.stats(which_stats[3)].to_n(3)}\t#{that_season.stats(which_stats[4)].to_n(3)}\t#{that_season.stats(which_stats[5)].to_n(3)}\t#{that_season.stats(which_stats[6)].to_n(3)}\t#{that_season.stats(which_stats[7)].to_n(3)}\t"
    end
    #puts closest.length

    pcts_p = pcts.p_bar
    pcts_std_dev = pcts.weighted_std_dev

    if pcts_p.nan?
      #puts "ERROR:\t#{pcts.sum("m")}\t#{pcts.sum("a")}"
    end
    #puts "#{next_season_stats.average}\t#{next_season_stats.std_dev}"
    #puts "#{pcts_p}\t#{pcts_std_dev}"
    #puts "#{this_season.stats("#{stat}p")}"
    #puts
    #[next_season_stats.average,next_season_stats.std_dev,pcts_p,pcts_std_dev]
    [pcts_p,pcts_std_dev]
  end

  def predict_wp_from_winshares
    ##this makes a prediction solely using winshares
    ##for use before 2014, the results were used in the fit and so they should not 
    ##be considered meaningful
    pct = $fn_wp_from_winshares.Eval(self.season.roster_wsp48.p)
    std_dev = $fn_wp_from_winshares_sd.Eval(self.season.roster_wsp48.p)
    [pct,std_dev]
  end

  def predict_wp_from_gsp
    ##this makes a prediction solely using gsp
    ##for use before 2014, the results were used in the fit and so they should not 
    ##be considered meaningful
    pct = $fn_wp_from_gsps.Eval(self.season.roster_gsp.p)
    std_dev = $fn_wp_from_gsps_sd.Eval(self.season.roster_gsp.p)
    [pct,std_dev]
  end

  def predict_wp_repeat_last_year
    ##this is a very boring prediction,
    ##you simply do as well this year as you did last year
    last_season = Team.findteam(psname).season
    pct = last_season.wp
    [pct.pct,pct.std_dev]
  end

  def predict_wp_from_league_avg
    ##this is a very boring prediction,
    ##everyone gets the same prediction, 0.500 and the league spread for last year
    [$team_mean_and_dev["wp.p"][season.year][0],$team_mean_and_dev["wp.p"][season.year][1]]
  end

end
