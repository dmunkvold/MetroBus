require "net/http"
require "uri"
require "json"


class MetroBot

  def http_request url
    uri = URI.parse(url)
    response = JSON.parse(Net::HTTP.get_response(uri).body)
  end

  def construct_url api_call, extra_info
    param = ""
    for i in extra_info
      param = param + '/' + i
    end
    url = api_call + param + "?format=json"
  end

  def get_route
    puts "Which bus route are you taking?"
    route = gets.chomp
  end

  def get_directions(route)
    direction_request = construct_url("http://svc.metrotransit.org/NexTrip/Directions", [route.to_s])
    #print direction_request
    directions = http_request direction_request
    #print directions.body
    if directions.length == 0
      puts "Error. Could not find route information, try again."
      route = get_route
      directions = get_directions route
    end
    directions
  end

  def get_direction directions
    puts "Which direction are you traveling?"
    available_directions = []
    for d in 0..(directions.length - 1)
      available_directions << directions[d]["Value"]
      print directions[d]["Value"] + " " + directions[d]["Text"] + "\n"
    end
    direction = gets.chomp
    if available_directions.include?(direction)== false
      puts "Invalid direction, try again."
      direction = get_direction directions
    end
    direction
  end

  def get_stop route, direction
    stop_request = construct_url("http://svc.metrotransit.org/NexTrip/Stops", [route.to_s, direction])
    stops = http_request stop_request
    puts "Which stop will you depart from?"
    for s in stops
      puts s["Value"] + " " + s["Text"]
    end
    stop = gets.chomp
    subset = false
    for j in 0..(stops.length - 1)
      if stops[j]["Value"] == stop
        subset = true
        break
      end
    end
    if subset == false
      puts = "Invalid stop, try again."
      stop = get_stop route, direction
    end
    stop
  end

  def get_time
    route = get_route
    directions = get_directions route
    direction = get_direction directions
    stop = get_stop route, direction
    #print "stop" + stop + "direction" + direction + "route " + route
    time_request = construct_url("http://svc.metrotransit.org/NexTrip", [route.to_s, direction, stop])
    timepoint = http_request time_request
    for i in 0..(timepoint.length - 1)
      if i >= 3
        break
      end
      puts "The next bus for route " + route + timepoint[i]["RouteDirection"] + " at " + timepoint[i]["Description"] + " will arrive in/at " + timepoint[i]["DepartureText"]
    end
  end

end

mb = MetroBot.new
mb.get_time
