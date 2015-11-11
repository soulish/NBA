require 'backbone.game'
require 'backbone.team.game'
require 'backbone.season'
require 'backbone.team.season'
require 'backbone.team.predictions'
require 'backbone.team.weights'
require 'backbone.team.averages'
require 'backbone.team.waverages'

class Team
  include MethodMissing
  attr_reader :code, :name, :games, :games_by_date, :season, :totals, :averages, :waverages

  @@teams = {}
  @@teams_by_year = {}
  @@lastteam = nil
  
  def initialize(code,name,conference,division,year,wins,losses,pct,conf_order,playoffs)
    @code = code
    @codeyear = "#{year} #{code}"
    @name = name
    @nameyear = "#{year} #{name}"
    @conference = conference
    @division = division
    @year = year
    @wins = wins
    @losses = losses
    @pct = pct
    @conf_order = conf_order
    @playoffs = playoffs
    @games = {}
    @games_by_date = {}
    @totals = {}
    @averages = {}
    @waverages = {}
    @seasons = nil
    @@teams[@codeyear] = self
    @@teams_by_year[year] ||= {}
    @@teams_by_year[year]["#{year} #{code}"] = self
  end

  def Team.findteam(name)
    right_team = nil
    right_team = @@teams[name]
    #puts name if right_team.nil?
    right_team
  end

  def Team.sort
    temp = @@teams
    temp = temp.sort_by{|k,v| k}
    @@teams = {}
    temp.each{|t| @@teams[t[0]] = t[1]}
  end

  def Team.last; @@lastteam; end
  def Team.each; @@teams.each{|name,team| yield team}; end
  def Team.by_year(year); @@teams_by_year[year].each{|name,team| yield team}; end

  def addgame(game_no,game)
    @games[game_no] = game
    @games_by_date[game.date] = game
  end

  def addseason(year,season)
    @season = season
  end

  def addaverage(average)
    @averages[average.date] = average
  end

  def addwaverage(waverage)
    @waverages[waverage.date] = waverage
  end

  def find_players_at_start_of_season
    teammates = {}
    year = self.year
    team = self.code
    Player.each do |player|
      season = player.season(year)
      next if season.nil?
      if season.team == team
        prev_season = player.season(year - 1)
        if (prev_season.nil? or prev_season.team != team)##he didn't play last year or wasn't on the team
          #I require him to have played in the first month of the season.
          #this should protect against most free agent signings,
          #but it could exclude an injured player who was traded to the team.
          first_game = player.games_by_season[year][0]
          teammates[player] = season  if (first_game.date - $season_parameters[year][0]).to_i <= 31
        elsif prev_season.team == team #he was on the team last year
          teammates[player] = season 
        end
      elsif season.team == "TOT" #he only played part of the season here. I only want players who start the season here
        ind = player.seasons.index(season)
        short_season = player.seasons[ind+1]
        if short_season.team == team #this was the first team he played on this year (removes players traded to team)
          prev_season = player.season(year - 1)
          if (prev_season.nil? or prev_season.team != team)##he didn't play last year or wasn't on the team
            #I require him to have played in the first month of the season.
            #this should protect against most free agent signings,
            #but it could exclude an injured player who was traded to the team.
            first_game = player.games_by_season[year][0]
            teammates[player] = season  if (first_game.date - $season_parameters[year][0]).to_i <= 31
          elsif prev_season.team == team #he was on the team last year
            teammates[player] = season 
          end
        end
      end
    end
    teammates
  end
  alias_method :fp_sos, :find_players_at_start_of_season

  def next_season_name
    name = nil
    case @codeyear
    when "1984 SDC" then name = "1985 LAC"
    when "1985 KCK" then name = "1986 SAC"
    when "1997 WSB" then name = "1998 WAS"
    when "2001 VAN" then name = "2002 MEM"
    when "2002 CHH" then name = "2003 NOH"
    when "2005 NOH" then name = "2006 NOK"
    when "2007 NOK" then name = "2008 NOH"
    when "2008 SEA" then name = "2009 OKC"
    when "2012 NJN" then name = "2013 BRK"
    when "2013 NOH" then name = "2014 NOP"
    else name = "#{self.year+1} #{self.code}"
    end
    name = nil if self.year == 2014
    name
  end
  alias_method :nsname, :next_season_name

  def prev_season_name
    name = nil
    case @codeyear
    when "1981 DAL" then name = nil #nils are expansion teams
    when "1989 CHH" then name = nil
    when "1989 MIA" then name = nil
    when "1990 MIN" then name = nil
    when "1990 ORL" then name = nil
    when "1996 TOR" then name = nil
    when "1996 VAN" then name = nil
    when "2005 CHA" then name = nil
    when "1985 LAC" then name = "1984 SDC"
    when "1986 SAC" then name = "1985 KCK"
    when "1998 WAS" then name = "1997 WSB"
    when "2002 MEM" then name = "2001 VAN"
    when "2003 NOH" then name = "2002 CHH"
    when "2006 NOK" then name = "2005 NOH"
    when "2008 NOH" then name = "2007 NOK"
    when "2009 OKC" then name = "2008 SEA"
    when "2013 BRK" then name = "2012 NJN"
    when "2014 NOP" then name = "2013 NOH"
    else name = "#{self.year-1} #{self.code}"
    end
    name
  end
  alias_method :psname, :prev_season_name

  def findgame_by_no(game_no)
    game = nil
    game = @games[game_no]
    if game.nil?
      puts "#{@name}\t#{game_no}\t\t#{@games.length}"
      exit
    end
    if game.game_no != game_no
      puts "couldn't find game: #{@name}\t#{game_no}"
      exit
    end
    game
  end

  def draft_probs
    wp,sigma = *self.predict_wp_distance2(10)
    #wp,sigma = *self.predict_wp_distance_combined(10)
    #wp,sigma = *self.predict_wp_from_winshares
    #wp,sigma = *self.predict_wp_repeat_last_year
    probs_fo,probs_pick = wp.nil? ? [nil,nil] : calc_draft_probs(wp,sigma,self.year)
    [wp,sigma,probs_fo,probs_pick]
  end
end

