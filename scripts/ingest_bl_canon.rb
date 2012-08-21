# TASK 1: grab csv
require 'csv'


csv_file = ARGV[0] || 'spreadsheets/canonical_renderings_by_john.csv'
lines = CSV.read(csv_file)

# skip header
lines.shift

out = []

def cEsc str
	str = Regexp.escape(str)
	str.gsub(/\//,'\/')
end

# TASK 2: find the `actuals`
actuals = lines.select { |e| e unless e[0].nil? or e[0].match(/(http)|(www)/)  }
# 'literals' are literals URLs
literals = lines.select { |e| e if e[0] =~ /(http)|(www)/  }

# and the '410's 
fourtens = actuals.map { |e| cEsc(e[0]) if e[2] == '410'  }


# write the '410's to one block
# TEST: does this take longer?
fourtens.delete_if{ |x| x.nil? }
str =<<-EOS
	location ~* .*(#{fourtens.join(")|(")}).* {
		return 410;
	}
EOS

out << str
test = []
actuals.each { |e|  
	next if e[2] == "410"	
	
	callstr = cEsc(e[0])
	str = ["\tlocation ~* .*#{callstr}.* {"]
	str << "\t\t# #{e[2]}"
	str << "\t\t rewrite ^ http://www.gov.uk break; # temp: point to home page" unless e[5]
	str << "\t\t rewrite ^ #{e[5]} permanent;" if e[5]
	str << "\t}"
	out << str.join("\n")
	test << e[0]
}


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

