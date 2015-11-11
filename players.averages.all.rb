letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","y","z"]
years = *(1980..2014)

letters = $letters unless $letters.nil?
years = $years unless $years.nil?
players = $players.nil? ? nil : $players
$player_count = 0

letters.each do |a| 
  #print "#{a}  \r"; $stdout.flush
  require "players/#{a}/players.#{a}.rb"
  dir = Dir.new("players/#{a}/")
  dir.entries.sort.each do |e|
    next unless e.include?(".averages")
    name = e.split("players.")[1].split(/.\d{4}.averages/)[0].gsub("_"," ")
    year = e.split(".averages")[0].split(".")[-1].to_i
    next unless years.include?(year)
    next unless players.include?(name) unless players.nil?
    print "#{a} #{name}...#{year}..................................  \r"; $stdout.flush
    require "players/#{a}/#{e}"
    $player_count += 1
  end
end


