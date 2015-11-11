letters = ["a","b","c","d","e","f","g","h","i","j","k","l","m","n","o","p","q","r","s","t","u","v","w","y","z"]
years = *(1980..2014)

letters = $letters unless $letters.nil?
years = $years unless $years.nil?

letters.each do |a| 
  print "#{a}  \r"; $stdout.flush
  require "players/#{a}/players.#{a}.rb"

  dir = Dir.new("players/#{a}/")
  dir.entries.each do |e|
    next unless e.include?("season")
    name = e.split("players.")[1].split(".season.")[0].gsub("_"," ")
    year = e.split(".season.")[0].split(".")[-1].to_i
    next unless years.include?(year)
    print "#{a} #{name}..................................  \r"; $stdout.flush
    require "players/#{a}/#{e}"
  end
end


