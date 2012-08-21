require 'uri'


fn = ARGV[0] || 'nginxrouting.test.txt'

lines = IO.readlines(fn)

lines.each do |line|
	line.strip!
	line = line.gsub(/\\/,'')
	r = `curl -sL -w "%{http_code}" "#{line}" -o /dev/null`
	puts  line + ": \t\t\t" + r 
end