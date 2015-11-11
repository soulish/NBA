years = *(1991..2014)
years = $years unless $years.nil?

years.each do |a| 
  print "#{a}  \r"
  $stdout.flush
  require "teams/#{a}/teams.#{a}.rb"
  if a >= 1991
    dir = Dir.new("teams/#{a}/")
    dir.entries.each do |e|
      next unless e.include?(".waverages.")
      require "teams/#{a}/#{e}"
    end
  end
end

