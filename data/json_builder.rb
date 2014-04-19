require 'json'

encoding_options = {
    :invalid           => :replace,  # Replace invalid byte sequences
    :undef             => :replace,  # Replace anything not defined in ASCII
    :replace           => '',        # Use a blank for those replacements
    :universal_newline => true       # Always break lines with \n
  }

acs = JSON.parse( IO.read("./all_counties_census.json") )
county_census = {}
acs.each do |c|
  county_census[c["GEO.id"]] = c
end

states = JSON.parse( IO.read("./us_states.geo.json") )
state_codes = {}

states["features"].each do |state|
  state_codes[state["id"]] = state["properties"]["name"]
end

all_counties = JSON.parse(IO.read("./us_counties.geo.json"))

county_files = {}

all_counties["features"].each do |county|
  county["properties"]["STATE_NAME"] = state_codes[county["properties"]["STATE"]]
  begin
    county["properties"]["populations"] = {}
    county["properties"]["populations"]["respop72010"] = county_census[county["properties"]["GEO_ID"]]["respop72010"]
    county["properties"]["populations"]["respop72011"] = county_census[county["properties"]["GEO_ID"]]["respop72011"]
    county["properties"]["populations"]["respop72012"] = county_census[county["properties"]["GEO_ID"]]["respop72012"]
    county["properties"]["populations"]["respop72013"] = county_census[county["properties"]["GEO_ID"]]["respop72013"]
  rescue
    #puts "Unable to add census data for #{county['properties']['NAME']}, county #{county['properties']['STATE_NAME']}"
  end

  county_files[state_codes[county["properties"]["STATE"]]] ||= []
  county_files[state_codes[county["properties"]["STATE"]]] << county
end


county_files.each do |key,val|
  val.each do |v|
    begin
      v["properties"]["NAME"] =~ /[^[:print:]]/
    rescue
      val.delete(v)
    end
  end

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
