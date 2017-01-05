require_relative 'mysql_db.rb'

SCHEDULER.every '10m', allow_overlapping: false, :first_in => 0 do |job|

	db = MyDb.conn

		sql1 = "SELECT COUNT(*) AS 'count' FROM commands cmd JOIN computers c USING (computerid) WHERE cmd.`command` = 100 AND cmd.`status` = 2 AND c.`LastContact` > DATE_ADD(NOW(), INTERVAL -10 MINUTE)"
		sql2 = "SELECT COUNT(DISTINCT computerid) AS 'count' FROM commands WHERE output LIKE '%downloaded and installed successfully%' AND dateupdated >=CURDATE()"
		sql3 = "SELECT COUNT(DISTINCT c.computerid) AS 'count' FROM commands cmd JOIN computers c ON (cmd.computerid = c.computerid) WHERE cmd.output LIKE '%No Updates to Install%'"
		sql4 = "SELECT SUM(subStrCount(output,'downloaded and installed successfully')) AS 'count' FROM `commands` WHERE commands.dateupdated >=CURDATE()"
		sql5 = "SELECT DISTINCT(c.name) AS 'Agent' FROM commands cmd JOIN computers c USING (computerid) WHERE cmd.`command`= 100 AND cmd.`status`= 2 AND c.`LastContact` > DATE_ADD(NOW(), INTERVAL -10 MINUTE) ORDER BY cmd.dateupdated DESC LIMIT 5"
		sql6 = "SELECT ed.`Value` AS 'version', COUNT(*) AS 'count' FROM `extrafielddata` ed JOIN computers c ON (c.`ComputerID` = ed.`ID`) WHERE ed.`ExtraFieldID`=775 AND c.OS LIKE '%windows 7%' GROUP BY ed.`Value` ORDER BY `count` DESC LIMIT 5"

		
		results1 = db.query(sql1).first
		results2 = db.query(sql2).first
		results3 = db.query(sql3).first
		results4 = db.query(sql4).first
		results5 = db.query(sql5)
		results6 = db.query(sql6)
		
		
		current_patchingnow = results1['count']
		current_patchedtoday = results2['count']
		current_patchedfully = results3['count']
		current_patchinstalls = results4['count']

		
		acctitems5 = results5.map do |row|
		row = {
		  :label => row['Agent'],
		}
end

		acctitems6 = results6.map do |row|
		row = {
		  :label => row['version'],
		  :value => row['count']
		}
end

	
		send_event('patchingnow', { value: current_patchingnow } )
		send_event('patchedtoday', { value: current_patchedtoday } )
		send_event('patchedfully', { value: current_patchedfully } )
		send_event('patchinstalls', { value: current_patchinstalls } )
		send_event('patchingnowlist' , { items: acctitems5 } )
		send_event('WUA7list' , { items: acctitems6 } )

		
	db.close
end