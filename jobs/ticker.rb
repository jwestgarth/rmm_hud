messages = [
  "Message of the day... 'FREE BEER FOR ALL!'- Brad H."
]

SCHEDULER.every '10m', :first_in => 0 do
	send_event( 'ticker', { :items => messages } )
end