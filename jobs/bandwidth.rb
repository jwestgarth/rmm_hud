require_relative 'mysql_db.rb'

#First, lets make a point or 8!

points = []
(1..8).each do |i|
  points << { x: i, y: 0 }
end
last_x = points.last[:x]

#Now, lets get to the point!

SCHEDULER.every '10s', allow_overlapping: false do

	db = MyDb.conn

		sql = "SELECT SUM(bandwidth) as 'sumb' FROM computers WHERE clientid = 1"

		result = db.query(sql).first
		total = 0
		total = result['sumb']
		total = total / 1000000.00
		total = total.round(2)

	points.shift
	last_x += 1
	points << { x: last_x, y: total }

		send_event("bwidth", points: points)

db.close
end
