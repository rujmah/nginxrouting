require 'date'
require 'rails'

# lg = 'spreadsheets/reviewomatic_prod_posts.log'
lg = ARGV[0] || 'nginx_list.txt'
lines = IO.readlines(lg)

lines.compact!
lines.sort_by! do |x| 
	
	DateTime.strptime($1.to_s,'%d/%b/%Y:%H:%M:%S') if x =~ /\[(.*) .*\]/
end

# counters
c = 0
u = 0 
pwd = 0


# reviews = []
clienta = []

h = {}
# actions = {}
reviewers = {}
logins = {}
reviewsh = {}


lines.reverse.each_with_index do |l,i|
	next if l.blank?
	# r = $1 if l =~ /reviews\/([a-z0-9]+) /
	d = $1 if l =~ /\[(.*) .*\]/
	# p d
	dt = DateTime.strptime(d.to_s,'%d/%b/%Y:%H:%M:%S')
	
	# reviews << [dt,r]

	items = l.split("\s")
	
	client = ''
	client  = items[14..items.length-5].join(" ").gsub(/\"/, '')

	clienta << client
	begin			
		h[client] += 1 if clienta.include?(client)
	rescue
		h[client] = 1	
	end

	# reviewers[client] = []
	# logins[client] = []

	if items[9] =~ /reviews\/([a-z0-9]{24,})/
		begin
			reviewers[client] << [dt, $1]
		rescue
			reviewers[client] = [[dt, $1]]
		end
		# review[dt] << [$1, client]

		c += 1 #unless client[1..7] =='Mozilla'
	elsif items[9] =~ /reviews\/undefined/
		
		u += 1
	elsif items[9] =~ /users\/password/
		begin
			logins[client] << dt unless logins[client].include?(dt)
		rescue
			logins[client] = [dt]
		end
		pwd += 1
	end	
end


# puts lines.length
puts "reviews:#{c}; undefined:#{u}; password:#{pwd}"

c = 0
# h.each{|k,v| puts "#{v}:#{k}"}
reviewers.each do |client,mash| 
	next if client.length == 0
			puts "\tcounter: #{c}"
	puts client  #"#{k}\n\t#{v}" #if k.length > 0
	curr = ''
	dpast = [] # debug - something's duplicating this 
	mash.each_with_index do |m,i|
		md = m[0].strftime("%Y-%m-%d")
		unless curr == md
			puts "\tcounter: #{c}"
			next if dpast.include? m[0]
			dpast << m[0]	
			curr = md 
			puts "\t#{md}"
			c = 1
		else
			c += 1
		end

		ctime = m[0].strftime("%H:%M:%S")
		puts "\t\t #{ctime} -  #{m[1]}"
	end 
end



# logins.each do |client,dates| 
# 	next if client.length == 0
# 	puts client
# 	dates.each_with_index do |p,i| 
# 		puts "\t" + p.strftime("%Y%m%d%H%M%s")
# 		# puts "\t\t" + client
# 		# next
# 		next if reviewers[client].nil?

# 		reviewers[client].each do |d,m|
# 			begin
# 				next unless d > p and d < dates[i+1]
# 				puts "\t\t ."
# 			rescue
# 				puts 'x'
# 			end
# 			# puts "\t\t" + m
# 		end
# 	end
# end

# reviews.order

# File.open(Time.now.strftime("reviews_prod_%Y%m%d%H%M%S.csv"), 'w') {|f| f.write(reviews.join("\n")) }
