require 'rubyStuff'
require 'backbone'
$years = nil
require 'teams.all'
Team.sort
$players = nil
require 'players.all'

Team.by_year(1993) do |team|
  puts "#{team.name}:\t#{team.wins}-#{team.losses}"
end

3.times{puts}

Player.each do |player|
  puts player.name
end
