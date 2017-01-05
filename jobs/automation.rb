require_relative 'mysql_db.rb'

SCHEDULER.every '60s', allow_overlapping: false, :first_in => 0 do |job|

	db = MyDb.conn

        sql1 = "SELECT COUNT(*) AS 'count' FROM computers;"
		sql2 = "SELECT IF(`os` LIKE '%microsoft%', IF(os LIKE '%Server%', 'Win Server','Win Workstation'), 'Other') AS `ostype`, COUNT(*) AS `count` FROM computers GROUP BY `ostype` ORDER BY `count` DESC"

        results1 = db.query(sql1).first
		results2 = db.query(sql2)

		current_agentcount = results1['count']
	
		acctitems2 = results2.map do |row|
		row = {
		  :label => row['ostype'],
		  :value => row['count'],
		}
end

		send_event('agentcount', { value: current_agentcount } )
		send_event('oslist', { items: acctitems2 } )
	
	
db.close
end
