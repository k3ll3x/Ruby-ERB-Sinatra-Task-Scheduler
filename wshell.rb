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

def updateItem(updatedItem, reason)
	#read json
	file = File.read("./public/history.json")
	data_hash = JSON.parse(file)
	new_data = []
	for dink in data_hash
		if (dink["id"] == updatedItem["id"].to_i)
			dink["comd"] = updatedItem["comd"]
			dink["duedate"] = updatedItem["duedate"]
			dink["srttime"] = updatedItem["srttime"]
			dink["endtime"] = updatedItem["endtime"]
			dink["id"] = updatedItem["id"].to_i
		end
		new_data.push(dink)
	end
	File.open("./public/history.json","w") do |file|
		file.write(new_data.to_json)
	end
end

def deleteDink(did, reason)
	#read json
	file = File.read("./public/history.json")
	data_hash = JSON.parse(file)
	new_data = []
	for dink in data_hash
		if dink["id"].to_i != did.to_i
			new_data.push(dink)
		else
			dink["reason"] = reason
			if reason != "forget"
				File.open("./public/archive", "a") do |file|
					text = "timestamp:\t%s\naction:\t%s\n\n\t%s\n\n" % [ dink["timestamp"], reason, dink["comd"] ]
					file.puts text
				end
			end
		end
	end
	File.open("./public/history.json","w") do |file|
		file.write(new_data.to_json)
	end
end

get "/history" do
	redirect back
end

post "/history" do
	params["cmd"] = save_thought(params)
	erb :wshell
end

get "/action" do
	redirect back
end

post "/action" do
	if params["reason"] == "edit"
		updateItem(params, params["reason"])
	elsif params["reason"] == "forget"
		deleteDink(params["id"], params["reason"])
	elsif params["reason"] == "done"
		deleteDink(params["id"], params["reason"])
	else
		updateItem(params, params["reason"])
	end
	#deleteDink(params["id"], reason)
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
