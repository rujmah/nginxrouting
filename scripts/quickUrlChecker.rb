require 'csv'

u = ''
r = ''
founda = []
faila = []
whata = []

c = ARGV[0]
lines = CSV.read(c)

puts lines.length.to_s

lines[0..100].each_with_index do |l,i|
	next if l[1].nil? 
	u = $1 if l[1] =~ /(\/bdotg\/.*$)/
	
	u = "https://www.businesslink.gov.uk" + u
	
	r = `curl -sL -w "%{http_code}" "#{u}" -o /dev/null`
	case r
	when '200'
		founda << u
		puts "yay!"

	when '404'
		faila << u
		puts "boo!"
	else
		whata << [r,u].join(',')	
		puts 'hmm....?'
	end  
	puts "processed #{i} lines" if i % 10 == 0
end

puts "Found (200): " + founda.length.to_s
puts "Failed (404): " + faila.length.to_s
puts "Unknown (?): " + whata.length.to_s

foundfn = "found_"+ Time.now.strftime("%Y%m%d%H%M%S") +".csv"
failfn = "failed_"+ Time.now.strftime("%Y%m%d%H%M%S") +".csv"
unkfn = "unknown_"+ Time.now.strftime("%Y%m%d%H%M%S") +".csv"
# write to file
# File.open(foundfn, 'w') {|f| f.write(founda.join("\n")) } unless founda.length == 0
# File.open(failfn, 'w') {|f| f.write(faila.join("\n")) } unless failfn.length == 0 
# File.open(unkfn, 'w') {|f| f.write(whata.join("\n")) } unless whata.length == 0

puts 'script complete'
