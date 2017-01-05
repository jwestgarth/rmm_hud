require_relative 'mysql_db.rb'

SCHEDULER.every '5m', allow_overlapping: false, :first_in => 0 do |job|

	db = MyDb.conn

		sql1 = "SELECT COUNT(*) AS 'count' FROM computers c2 JOIN `drives` d USING (`ComputerID`) WHERE d.letter = 'C' AND d.free < 2048;"
		sql2 = "SELECT c2.`name` AS 'Agent', CONCAT(d.free, ' k') AS 'Space' FROM computers c2 JOIN `drives` d USING (`ComputerID`) WHERE d.letter = 'C' AND d.free < 2048 ORDER BY d.free ASC LIMIT 5;"

		results1 = db.query(sql1).first
		results2 = db.query(sql2)

		current_lowsysdrive = results1['count']
		
		acctitems2 = results2.map do |row|
		row = {
		  :label => row['Agent'],
		  :value => row['Space'],
		}
 end
		
		send_event('lowsysdrive', { value: current_lowsysdrive } )
		send_event('lowsysdrivelist', { items: acctitems2 } )

	db.close
end
