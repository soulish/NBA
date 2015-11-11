years = *(1980..2014)
years = $years unless $years.nil?

years.each do |a| 
  print "#{a}  \r"
  $stdout.flush
  require "teams/#{a}/teams.#{a}.rb"
end
