require 'backbone.game'
require 'backbone.player.game'
require 'backbone.season'
require 'backbone.player.season'
require 'backbone.player.averages'
require 'backbone.player.waverages'
require 'backbone.player.weights'
require 'backbone.player.predictions'

class Player
  include MethodMissing
  attr_reader :name, :start_year, :end_year, :position, :height, :weight, :birthday, :college, :seasons, :games, :games_by_date, :games_by_season, :college_seasons, :draft_year, :draft_round, :draft_pick, :draft_team, :averages, :waverages, :waverages_by_season, :averages_by_season
  @@players = {}
  @@lastteam = nil
  
  def initialize(name,start_year,end_year,position,height,weight,birthday,college,initial)
    @name = name
    @start_year = start_year
    @end_year = end_year
    @position = position
    @height = height
    @weight = weight
    @birthday = birthday
    @college = college
    @initial = initial
    @draft_year,@draft_round,@draft_pick,@draft_team = nil,nil,nil,nil
    @seasons = []
    ##takes care of multiple players with the same name
    if @@players[name].nil?
      @@players[name] = self
    else
      for i in 1..100
        if @@players["#{name} #{i}"].nil?
          @@players["#{name} #{i}"] = self
          puts "#{name} #{i}"
          break
        end
      end
    end
    @college_seasons = []
    @games = {}
    @games_by_date = {}
    @games_by_season = {}
    @averages = {}; @averages_by_season = {}
    @waverages = {}; @waverages_by_season = {}
    @@lastplayer = self
  end

  def Player.sort
    temp = @@players
    temp = temp.sort_by do |k,v|
      k.split(" ").last
    end
    @@players = {}
    temp.each do |t|
      @@players[t[0]] = t[1]
    end
    @@players
  end

  def Player.last; @@lastplayer; end
  def Player.length; @@players.length; end
  def Player.each; @@players.each{|name,player| yield player}; end

  def addseason(season)
    @seasons.push season
    season.setage(((Date.new(season.year,2,1).jd-birthday.jd)/365.25).floor)
  end

  def addgame(game_no,game)
    # if (game.date.month >= 9 and game.date.year != game.season - 1)
    #   puts "a #{@name}\t#{game_no}\t#{game.date.year}\t#{game.season - 1}"
    # end
    # if (game.date.month < 8 and game.date.year != game.season)
    #   puts "b #{@name}\t#{game_no}\t#{game.date.year}\t#{game.season}"
    # end
    # if (game_no != 1 and @games[game_no-1].nil?)
    #   puts "c #{@name}\t#{game_no}"
    # end
    # if (game_no != 1 and !@games[game_no].nil?)
    #   puts "d #{@name}\t#{game_no}"
    # end
    # if (game_no != 1 and @games[game_no-1].nil? and game.season == 2015)
    #   puts "ERROR:::: #{@name}\t#{game_no}"
    # end

    #puts "#{self.name}\t#{game.season}\t#{game_no}"

    @games[game_no] = game

    @games_by_date[game.date] = @games[game_no]
    @games_by_season[game.season] = [] if @games_by_season[game.season].nil?
    @games_by_season[game.season].push @games[game_no]
  end

  def addaverage(year,average)
    @averages[average.date] = average
    @averages_by_season[year] ||= {}
    @averages_by_season[year][average.date] = average
  end

  def addwaverage(year,waverage)
    @waverages[waverage.date] = waverage
    @waverages_by_season[year] ||= {}
    @waverages_by_season[year][waverage.date] = waverage
  end

  def set_draft_info(year,round,pick,team)
    @draft_year = year
    @draft_round = round
    @draft_pick = pick
    @draft_team = team
  end

  def addcollege(college_season)
    @college_seasons.push college_season
  end

  def season(year,teamname = nil)
    s = nil
    @seasons.each do |season|
      if teamname.nil?
        s = season if season.year == year
        break if season.year == year
      else
        s = season if (season.year == year and season.team == teamname)
        break if (season.year == year and season.team == teamname)
      end
    end
    s
  end

  def findgame_by_no(car_game_no)
    game = nil
    game = @games[car_game_no]
    if game.nil?
      puts "#{@name}\t#{car_game_no}\t\t#{@games.length}"
      exit
    end
    if game.car_game_no != car_game_no
      puts "couldn't find game: #{@name}\t#{car_game_no}"
      exit
    end
    game
  end

  def played_year(year)
    tf = false
    @seasons.each do |season|
      if season.year == year
        tf = true
        break
      end
    end
    tf
  end

  def played_year_rough(year)
    tf = false
    tf = true if year.between?(@start_year,@end_year)
    tf
  end

  def Player.findplayer(name)
    right_player = nil
    right_player = @@players[name]
    #puts name if right_player.nil?
    right_player
  end
end
