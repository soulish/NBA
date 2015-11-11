class Draft
  
  attr_reader :picks,:year

  @@drafts = {}

  def initialize(year)
    @year = year
    @picks = {}
    @@drafts[year] = self
  end

  def add_pick(round,pick,team,teamname,name,college,num_years,games,mp,pts,trb,ast,fgp,threep,ftp,ws,wsp48)
    draft_pick = DraftPick.new(round,pick,team,teamname,name,college,num_years,games,mp,pts,trb,ast,fgp,threep,ftp,ws,wsp48)
    @picks[pick] = draft_pick

    player = Player.findplayer(name)
    player.set_draft_info(year,round,pick,team) unless (mp == 0 or player.nil?)
  end

  def Draft.findyear(year); @@drafts[year]; end
  def Draft.each; @@drafts.each{|year,draft| yield draft}; end
end

class DraftPick
  include MethodMissing

  attr_reader :name

  def initialize(round,pick,team,teamname,name,college,num_years,games,mp,pts,trb,ast,fgp,threep,ftp,ws,wsp48)
    @round = round
    @pick = pick
    @team = team
    @teamname = teamname
    @name = name
    @college = college
    @num_years = num_years
    @games = games
    @mp = mp
    @pts = pts
    @trb = trb
    @ast = ast
    @fgp = fgp
    @threep = threep
    @ftp = ftp
    @ws = ws
    @wsp48 = wsp48
  end

end

