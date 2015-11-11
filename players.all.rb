letters = ["a","b","c","d","e","f","g","h",
           "i","j","k","l","m","n","o","p",
           "q","r","s","t","u","v","w","y","z"]
letters = $letters unless $letters.nil?
players = $players.nil? ? nil : $players

letters.each do |a| 
  print "#{a}           \r"
  $stdout.flush
  require "players/#{a}/players.#{a}.rb"
end
