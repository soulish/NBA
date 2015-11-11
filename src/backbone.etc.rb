def find_game_teammates(team,date,year)##can't get year from date because season spans years
  teammates = {}
  Player.each do |player|
    next if player.games_by_season[year].nil?
    game = player.games_by_date[date]
    next if game.nil?
    teammates[player] = game if team == game.team
  end
  teammates
end

def calc_draft_probs(wp,sigma,year)
  ###fo means finishing order
  ###pick means draft order

  n_teams = $teams_by_year[year].length
  probs_fo = {}
  probs_pick = {}
  (1..n_teams).each{|fo| probs_fo[fo] = 0;probs_pick[fo] = 0}

  fn = TF1.new("fn","gaus")
  fn_fo = TF1.new("fn_fo","gaus")
  fn.SetParameters(1/($games_per_season[year]*sigma*Math::sqrt(2*Math::PI)),wp,sigma)

  sum = 0
  ($games_per_season[year]+1).times do |wins|
    prob_wins = fn.Eval(wins/$games_per_season[year].to_f)#.to_N(5)

    if prob_wins > 0
      fo_mean = $fn_fo_vs_wp.Eval(wins/$games_per_season[year].to_f)#.to_N(5)
      fo_std_dev = $fn_fo_std_dev.Eval(wins/$games_per_season[year].to_f)#.to_N(5)
      fn_fo.SetParameters(1/(fo_std_dev*Math::sqrt(2*Math::PI)),fo_mean,fo_std_dev)
      (1..n_teams).each do |fo|
        prob_fo = fn_fo.Eval(fo)#.to_N(5)
        probs_fo[fo] += (prob_fo*prob_wins) if prob_fo > 0
      end
    end
  end

  (1..n_teams).each do |fo|
    if (fo <= 14)
      (1..14).each{|pick| probs_pick[pick] += (probs_fo[fo]*$lottery_odds[fo][pick-1])}
    elsif fo > 14
      probs_pick[fo] = probs_fo[fo]#.to_N(5)
    end
  end

  return [probs_fo,probs_pick]
end

##used when the finishing order has been specified, regardless of wp
def calc_draft_probs_fo(fo,n_teams = 30)
  ###fo means finishing order
  ###pick means draft order

  probs_fo = {}
  probs_pick = {}
  (1..n_teams).each{|fo| probs_fo[fo] = 0;probs_pick[fo] = 0}
  probs_fo[fo] = 1

  fn_fo = TF1.new("fn_fo","gaus")

  if (fo <= 14)
    (1..14).each{|pick| probs_pick[pick] += (probs_fo[fo]*$lottery_odds[fo][pick-1])}
  elsif fo > 14
    probs_pick[fo] = probs_fo[fo]#.to_N(5)
  end

  return probs_pick
end

module SigFigs
  def to_n(n)
    sprintf("%.#{n}f",self)
  end

  def to_N(n)
    sprintf("%.#{n}f",self).to_f
  end
end

def get_max(hash)
  max = 0
  max_key = nil
  hash.each_pair do |key,val|
    max_key = key if val > max
    max = val if val > max
  end
  max_key
end


class Fixnum
  include SigFigs
  def in_between(start,stop)
    tf = false
    tf = true if (start <= self and stop >= self)
    tf
  end
end

class Float
  include SigFigs
  def in_between(start,stop)
    tf = false
    tf = true if (start <= self and stop >= self)
    tf
  end
end

class Array
  def average
    sum = 0
    self.each{|v| sum += v.to_f}
    sum/self.length.to_f
  end

  def sum
    sum = 0
    self.each{|v| sum += v.to_f}
    sum
  end

  def std_dev
    average = self.average
    sum = 0
    self.each{|pt| sum += (pt-average)**2/(self.length.to_f-1)}
    Math::sqrt(sum)
  end

  def rms
    average = self.average
    sum = 0
    self.each{|pt| sum += (pt-average)**2/(self.length.to_f)}
    Math::sqrt(sum)
  end

  def normalize
    norm = self.sum
    normalized = []
    self.each{|i| normalized.push i/norm}
    normalized
  end
end
