#NOTE: Must install Watir and Twilio Gems.
#NOTE: Must fill-in personal Twilio account_sid and auth_token below.
#NOTE: Change locations to choices that best match your location.
#NOTE: Simply run in terminal and keep in background.

#Require Watir and Trilo components
require 'watir'
require 'webdrivers'
require 'twilio-ruby'

#Main thread to begin checking
def main
  
  puts "starting virtual browser"
  
  #Creates headless virtual browser and pulls page
  browser = Watir::Browser.new :chrome, headless: true
  browser.goto 'https://am-i-eligible.covid19vaccine.health.ny.gov'
  
  puts "page loaded - waiting 15 seconds for javascript"
  
  sleep 15
  
  puts "checking..."
  
  #Finds appropriate table on webpage
  results = browser.table(:id => 'statePods_table').hashes
  
  #Searches table for noted site locations, then calls checkAvailable()
  results.each { |x|
    if x.to_s.include? "Jones Beach"
      checkAvailable(x.to_s, "Jones Beach")
    elsif x.to_s.include? "SUNY Stony Brook"
      checkAvailable(x.to_s, "SUNY Stony Brook")
    end
  }
  
  browser.close
end

#Check location - pass table results and location name
def checkAvailable(results, location)
  
  time = Time.now
  
  #checks if location has appointments
  if results.include? "No Appointments Available Currently"
    puts time.inspect + " : " + location.downcase + "- NO appointment found"
  else
    puts time.inspect + " : " + location.downcase + "- YES appointment found"
    
    #Starts Twilio to send text message
    account_sid = '000000000000000000000000000000'
    auth_token = '000000000000000000000000000000'
    client = Twilio::REST::Client.new(account_sid, auth_token)

    from = '+0000000000' # Your Twilio number
    toPerson = '+0000000000' # Your mobile phone number
        
    #Sends message as text notification and includes quick link
    client.messages.create(
    from: from,
    to: toPerson,
    body: "Appointment has been found at " + location + ". https://am-i-eligible.covid19vaccine.health.ny.gov"
    )
    puts 'text notification sent'
    
    #Waits 1-hour before checking again to avoid spamming
    puts "waiting 60 minutes before checking again"
    sleep 900
    puts "waiting 45 minutes before checking again"
    sleep 900
    puts "waiting 30 minutes before checking again"
    sleep 900
    puts "waiting 15 minutes before checking again"
    sleep 900
    
    puts "resuming..."
  end
end

puts "COVID-19 Appointment Checker"

while true
  #Loops until terminated - waits 1 minute between calls
  main
  puts "waiting 1 minute before checking again"
  sleep 60
end