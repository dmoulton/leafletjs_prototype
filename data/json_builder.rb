require 'json'

states = JSON.parse( IO.read("./us_states.geo.json") )
state_codes = {}

states["features"].each do |state|
  state_codes[state["id"]] = state["properties"]["name"]
end

all_counties = JSON.parse(IO.read("./us_counties.geo.json"))

county_files = {}

all_counties["features"].each do |county|
  county["properties"]["STATE_NAME"] = state_codes[county["properties"]["STATE"]]
  county_files[state_codes[county["properties"]["STATE"]]] ||= []
  county_files[state_codes[county["properties"]["STATE"]]] << county
end


county_files.each do |key,val|
  output_hash = {"type"=> "FeatureCollection"}
  output_hash["features"] = county_files[key]

  File.open("states/#{key.downcase.tr(" ", "_")}.counties.geo.json","w") do |f|
    begin
      f.write(output_hash.to_json)
    rescue
      puts "Unable to create file for #{key}"
    end
  end
end
