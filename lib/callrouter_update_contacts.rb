# First argument passed sets the number of minutes, defaults to 4 if not passed

require 'rubygems'
require 'mysql2'
require 'faraday'

client = Mysql2::Client.new(
  host: 'localhost', 
  username: 'root',
  database: 'asterisk'
)

minutes = 4
unless ARGV[0].nil?
  minutes = ARGV[0]
  #puts "Minutes Set: #{minutes}"
end

results = client.query("SELECT length_in_sec,lead_id,campaign_id,term_reason FROM vicidial_closer_log WHERE list_id='909' AND call_date > DATE_SUB(NOW(), INTERVAL #{minutes} MINUTE);")

results.each do |result|
  #puts result
  root_url = result['campaign_id'].include?('d') ? 'https://d2bb-172-248-52-177.ngrok.io' : 'https://trackerdeploy.herokuapp.com'
  
  response = Faraday.put(
    "#{root_url}/contacts", {
      lead_id: result['lead_id'],
      length_in_sec: result['length_in_sec'],
      term_reason: result['term_reason'],
      key: '5vdtzvdGNVus'
    }
  )

  #puts response.body
  sleep (0.1)
end
