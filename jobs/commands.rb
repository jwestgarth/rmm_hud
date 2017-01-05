require_relative 'mysql_db.rb'

SCHEDULER.every '30s', allow_overlapping: false, :first_in => 0 do |job|

	db = MyDb.conn

		sql1 = "SELECT c.name AS 'agent', COUNT(*) AS 'cmdcount' FROM commands cmd LEFT JOIN computers c ON (c.computerid = cmd.computerid) WHERE cmd.status = 2 AND cmd.DateUpdated > TIME(DATE_SUB(NOW(), INTERVAL 1 HOUR)) GROUP BY cmd.computerid ORDER BY COUNT(*) DESC LIMIT 5"
		sql2 = "SELECT COUNT(*) as 'count' FROM commands cmd LEFT JOIN computers c ON (c.computerid = cmd.computerid) WHERE cmd.status = 2 AND cmd.DateUpdated > TIME(DATE_SUB(NOW(), INTERVAL 1 HOUR))"
		
		
		results1 = db.query(sql1)
		results2 = db.query(sql2).first

		
		current_stuckcommandcount = results2['count']
		
		
		acctitems1 = results1.map do |row|
		row = {
		  :label => row['agent'],
		  :value => row['cmdcount'],
		}
end

		send_event('stuckcommandlist' , { items: acctitems1 } )
		send_event('stuckcommandcount' , { value: current_stuckcommandcount } )
		
	db.close
end