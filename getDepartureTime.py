import requests

class metroBot:
    
    def httpRequest(self, url):
        r = requests.get(url)
        return r.json()
    
    
    def constructURL(self, apiCall, extraInfo):
        param = ""
        for i in extraInfo:
            param = param + '/' + i
        url = apiCall + param + '?format=json'
        return url
        
    def getRoute(self):
        print "Which bus route are you taking?"
        route = raw_input()
        return route
    
    def getDirections(self, route):
        directionsRequest = self.constructURL('http://svc.metrotransit.org/NexTrip/Directions',  [str(route)])
        directions = self.httpRequest(directionsRequest)
        if len(directions)==0:
            print "error: could not find information, try again"
            route = self.getRoute()
            directions = self.getDirections(route)
        print directions    
        return directions        
        
    def getDirection(self, directions):
        print "Which direction are you traveling?"
        for d in range(0, len(directions)):
            print directions[d]['Value'], directions[d]['Text']
        direction = raw_input()  
        if int(direction) < 1 or int(direction) > 4:
            print "invalid direction, try again"
            direction = self.getDirection(directions)
                                                      
        return direction
        
    def getStop(self, route, direction):
        stopRequest = self.constructURL('http://svc.metrotransit.org/NexTrip/Stops', [str(route), direction])
        stops = self.httpRequest(stopRequest)
        print "Which stop will you depart from?"
        for s in stops:
            print s['Value'], s['Text']
        stop = raw_input()
        subset = False
        for j in range(0, len(stops)):
            if stops[j]['Value'] == stop:
                subset = True
                break;
        if subset == False:
            print "invalid stop, try again"
            stop = self.getStop(route, direction)
        return stop
        
    def getTime(self):
        route = self.getRoute()
        directions = self.getDirections(route)
        direction = self.getDirection(directions)
        stop = self.getStop(route, direction)
        timeRequest = self.constructURL('http://svc.metrotransit.org/NexTrip', [str(route), direction, stop])
        timepoint = self.httpRequest(timeRequest)
        for i in range(0, len(timepoint)): 
            if i >= 3: break
            print "The next bus for route", route, timepoint[i]['RouteDirection'], "at", timepoint[i]['Description'], "will arrive in/at ", timepoint[i]['DepartureText']
            
        

def checkIfEmpty(thing):
    if len(thing)==0:
        print "could not find information, try again"
    
mb = metroBot()
mb.getTime()
        