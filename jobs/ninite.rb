require_relative 'mysql_db.rb'

SCHEDULER.every '10m', allow_overlapping: false, :first_in => 0 do |job|

        db = MyDb.conn

		sql1 = "SELECT COUNT(*) as 'count' FROM `plugin_mp_ninite_history` WHERE `action` IN (2,3) AND `timestamp` >=CURDATE()"
		sql2 = "SELECT COUNT(*) as 'count' FROM `plugin_mp_ninite_history` WHERE `action` IN (2,3) AND `timestamp` > DATE_ADD(NOW(), INTERVAL -7 DAY)"
		
		results1 = db.query(sql1).first
		results2 = db.query(sql2).first
		
		current_niniteday = results1['count']
		current_niniteweek = results2['count']
	
		send_event('niniteday', { value: current_niniteday } )
		send_event('niniteweek', { value: current_niniteweek } )

db.close
end
