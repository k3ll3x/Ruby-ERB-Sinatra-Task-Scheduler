require "sinatra"
require "json"

#set :port, 80
#set :port, 88

def save_thought(n_dink)
	#format thought
	puts n_dink
	#n_dink["duedate"] = ;
	n_dink["timestamp"] = Time.now.getutc
	n_dink["id"] = (Random.rand() * 10000).to_i
	#read json
	file = File.read("./public/history.json")
	data_hash = JSON.parse(file)
	new_data = []
	for dink in data_hash
		new_data.push(dink)
	end
	new_data.push(n_dink)
	new_data = new_data.sort_by { |hash| hash['duedate'].tr('-','').to_i }
	File.open("./public/history.json","w") do |file|
		file.write(new_data.to_json)
	end
	new_data
end

def deleteDink(did, reason)
	#read json
	file = File.read("./public/history.json")
	data_hash = JSON.parse(file)
	new_data = []
	for dink in data_hash
		if !(dink["id"] == did.to_i)
			new_data.push(dink)
		else
			dink["reason"] = reason
			File.open("./public/archive.json", "a") do |file|
				file.puts dink.to_json
				file.puts "\n"
			end
		end
	end
	File.open("./public/history.json","w") do |file|
		file.write(new_data.to_json)
	end
end

post "/history" do
	params["cmd"] = save_thought(params)
	erb :wshell
end

post "/delete" do
	reason = ""
	if params["edit"] == "on"
		reason = "edit"
	elsif params["forget"] == "on"
		reason = "forget"
	elsif params["done"] == "on"
		reason = "done"
	end
	deleteDink(params["id"], reason)
	#Load from file and send params
	file = File.read("./public/history.json")
	data_hash = JSON.parse(file)
	params["cmd"] = data_hash
	erb :wshell
end

get "/" do
	#Load from file and send params
	file = File.read("./public/history.json")
	data_hash = JSON.parse(file)
	params["cmd"] = data_hash
	erb :wshell
end


get "/delete_all" do
	fork { exec('echo "[]" > public/history.json') }
	erb :wshell
end

get "/history" do
	#Load from file and send params
	file = File.read("./public/history.json")
	data_hash = JSON.parse(file)
	params["cmd"] = data_hash
	erb :commands
end
