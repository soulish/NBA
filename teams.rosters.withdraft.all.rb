years = *(1980..2014)
years = $years unless $years.nil?

years.each do |a| 
  print "#{a}  \r"
  $stdout.flush
  require "teams/#{a}/teams.#{a}.rb"
  if a >= 1985
    dir = Dir.new("/home/soulish/ruby/nba2015/teams/#{a}/")
    dir.entries.each do |e|
      next unless e.include?(".season.")
      require "teams/#{a}/#{e}"
    end
    dir.entries.each do |e|
      next unless e.include?(".roster.withdraft.rb")
      require "teams/#{a}/#{e}"
    end
  end
end
