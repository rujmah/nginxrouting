require 'uri'


fn = ARGV[0] || 'nginxrouting.test.txt'

lines = IO.readlines(fn)

puts "testing #{lines.count} urls"

success = []
fail =[]

lines.each do |line|
	line.strip!
	line = line.gsub(/\\/,'')
	r = `curl -sL -w "%{http_code}" "#{line}" -o /dev/null`
	puts  line + ": \t\t\t" + r 
	case r 
	when '404'
		fail << line
	else
		success << line
	end
end

puts "you had:"
puts "#{success.count} successful urls"
puts "#{fail.count} returned"
