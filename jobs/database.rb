require_relative 'mysql_db.rb'

SCHEDULER.every '10s', allow_overlapping: false, :first_in => 0 do |job|

        db = MyDb.conn

        sql1 = "SELECT COUNT(*) AS 'count' FROM information_schema.PROCESSLIST;"
		sql2 = "SELECT SUM(ROUND(((data_length + index_length)/1024/1024/1024),2)) AS 'dbsize' FROM information_schema.TABLES WHERE table_schema LIKE 'labtech';"
		sql3 = "SELECT table_name AS `table`, ROUND(((data_length + index_length) / 1024 / 1024), 0) `size` FROM information_schema.TABLES WHERE table_schema = 'labtech' AND table_name NOT LIKE '%plugin%' ORDER BY (data_length + index_length) DESC LIMIT 5;"
		sql4 = "SELECT FORMAT(BufferPoolPages*PageSize/POWER(1024,3),2) AS 'InnoDB' FROM (SELECT variable_value BufferPoolPages FROM information_schema.global_status WHERE variable_name = 'Innodb_buffer_pool_pages_data') A, (SELECT variable_value PageSize FROM information_schema.global_status WHERE variable_name = 'Innodb_page_size') B;"

        results1 = db.query(sql1).first
		results2 = db.query(sql2).first
		results3 = db.query(sql3)
		results4 = db.query(sql4).first

		current_dbconnections = results1['count']
		current_dbsize = results2['dbsize']
		current_innodb = results4['innodb']
		
		acctitems3 = results3.map do |row|
		row = {
		  :label => row['table'],
		  :value => row['size'],
		}
end

		send_event('dbconnections', { value: current_dbconnections } )
		send_event('dbsize', { value: current_dbsize } )
		send_event('dbtables', { items: acctitems3 } )
		send_event('innodb', { value: current_innodb } )
		
db.close
end
