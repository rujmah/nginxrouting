require 'CSV'

puts 'DEBUG: script start'


# spreadsheets
logs_fn = 'spreadsheets/akamai-70750-Total-stripped.csv'
bl_fn = 'spreadsheets/bens_full_bl.csv'

# get ben's CSV and rip itemids and topicids to memory
bl_lines = CSV.read(bl_fn, :col_sep => "\t")
bl_itemids = []
bl_topicids = []

def get_ids lines, n, out_arry
	out_arry = lines.map{ |l| 
		l[n].to_i.to_s unless l[n].nil? or l[n].length < 3 or out_arry.include? l[n].to_i.to_s 
	}
end
bl_itemids = get_ids bl_lines, 4, bl_itemids
bl_topicids = get_ids bl_lines, 5, bl_topicids


# iterate through akamai logs and compare any itemids or topicids found
logs_lines = File.readlines(logs_fn)

logs_hasit = [] 
logs_notit = []

logs_hastp = []
logs_nottp = []


def find_ids id_arry, has_arry, not_arry, rgx, line 
	out = $1 if line =~ rgx 
	unless out.nil? or out.length < 3
		if id_arry.include? out
			# has_arry << out unless has_arry.include? out
			has_arry << [out,line].join(',') unless has_arry.include? out
		else
			# not_arry << out unless not_arry.include? out
			not_arry << [out,line].join(',') unless not_arry.include? out
		end
	end
end


logs_lines.each_with_index{ |l,i| 
# logs_lines[0..100].each_with_index{ |l,i| 
	find_ids bl_itemids, logs_hasit, logs_notit, /itemid=([\d]{10,})/i, l
	find_ids bl_topicids, logs_hastp, logs_nottp, /topicid=([\d]{10,})/i, l
	puts "processed #{i} lines" if i % 1000 == 0 
	}

p logs_lines.length

p logs_hasit.length
p logs_notit.length

p logs_hastp.length
p logs_nottp.length

fn1 = "itemidsnotfound_"+ Time.now.strftime("%Y%m%d%H%M%S") +".csv"
fn2 = "topicidsnotfound_"+ Time.now.strftime("%Y%m%d%H%M%S") +".csv"
File.open(fn1, 'w') {|f| f.write(logs_notit.join("\n")) }
File.open(fn2, 'w') {|f| f.write(logs_nottp.join("\n")) }


puts 'DEBUG: script end'