years = *(1980..2014)
years = $years unless $years.nil?

years.each do |a| 
  print "#{a}  \r"
  $stdout.flush
  require "/home/soulish/ruby/nba2015/teams/#{a}/teams.#{a}.rb"
  dir = Dir.new("/home/soulish/ruby/nba2015/teams/#{a}/")
  dir.entries.each do |e|
    next unless e.include?(".games.")
    require "/home/soulish/ruby/nba2015/teams/#{a}/#{e}"
  end
end
