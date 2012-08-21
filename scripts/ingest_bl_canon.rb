# TASK 1: grab csv
require 'csv'

def cEsc str
	str = Regexp.escape(str)
	str.gsub(/\//,'\/')
end

csv_file = ARGV[0] || 'spreadsheets/canonical_renderings_by_john.csv'
lines = CSV.read(csv_file)

# skip header
lines.shift

out = []
test = []


# TASK 2: find the `actuals`
actuals = lines.select { |e| e unless e[0].nil? or e[0].match(/(http)|(www)/)  }

# and the '410's 
fourtens = actuals.map { |e| cEsc(e[0]) if e[2] == '410'  }

# write the '410's to one block
# TEST: does this take longer?
fourtens.delete_if{ |x| x.nil? }
if fourtens
	str =<<-EOS
	location ~* .*(#{fourtens.join(")|(")}).* {
		return 410;
	}
EOS
	out << str
end

actuals.each do |e|  
	next if e[2] == "410"	
	
	callstr = cEsc(e[0])
	str = ["\tlocation ~* .*#{callstr}.* {"]
	str << "\t\t# #{e[2]}"
	str << "\t\trewrite ^ http://www.gov.uk break; # temp: point to home page" unless e[5]
	str << "\t\trewrite ^ #{e[5]} permanent;" if e[5]
	str << "\t}"
	out << str.join("\n")
	test << e[0]
end

# NOTE: Not using literal URLs at the moment 
# 'literals' are literals URLs
# literals = lines.select { |e| e if e[0] =~ /(http)|(www)/  }
# ltest = []
# literals.each do |e|
# 	url = $2 if e[0] =~ /(http:\/\/)*www.businesslink.gov.uk\/(.*)$/
# 	next unless url
# 	puts e[0], url
# 	str = ["\tlocation = /x#{url} {"]
# 	if e[2] == "410"
# 		str << "\t\treturn 410;"
# 	else
# 		str << "\t\t# #{e[2].gsub(/\n/,' ')}"
# 		str << "\t\trewrite ^ http://www.gov.uk break; # temp: point to home page" unless e[5]
# 		str << "\t\trewrite ^ #{e[5]} permanent;" if e[5]
# 	end
# 	str << "\t}"
# 	out << str.join("\n")
# 	test << url
# end



out = [
	"server {
	server_name nginxrouting.dev.gov.uk;",
	out,
	"}"
].join("\n")

File.open('nginxrouting.conf','w'){ |f| f.write(out) }

puts 'created nginx conf file'

# TEST, TEST, TEST!!!
# generate a list of test urls

test = fourtens + test
testfile = test.map { |t| "http://nginxrouting.dev.gov.uk/" + t }

File.open('nginxrouting.test.txt','w'){ |f| f.write(testfile.join("\n")) }
puts 'created test urls file'

