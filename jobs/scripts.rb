require_relative 'mysql_db.rb'

SCHEDULER.every '5s', allow_overlapping: false, :first_in => 0 do |job|

        db = MyDb.conn

		sql1 = "SELECT COUNT(*) as 'count' FROM `runningscripts` WHERE `step` > 0"
		sql2 = "SELECT COUNT(*) as 'count' FROM `runningscripts` WHERE `step` = 0 AND `Start` < DATE_SUB(NOW(), INTERVAL 30 MINUTE)"
		sql3 = "SELECT COUNT(*) as 'count' FROM `runningscripts` WHERE scriptid = 55"
		
		results1 = db.query(sql1).first
		results2 = db.query(sql2).first
		results3 = db.query(sql3).first
		
		current_scriptsrunning = results1['count']
		current_scriptspending = results2['count']
		current_onboardingnow = results3['count']
	
		send_event('scriptsrunning', { value: current_scriptsrunning } )
		send_event('scriptspending', { value: current_scriptspending } )
		send_event('onboardingnow', { value: current_onboardingnow } )

db.close
end
