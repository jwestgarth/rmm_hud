require_relative 'mysql_db.rb'

SCHEDULER.every '30s', allow_overlapping: false, :first_in => 0 do |job|

	db = MyDb.conn

	sql = "SELECT COUNT(*) as 'count' FROM Computers WHERE LastContact < DATE_ADD(NOW(),Interval -120 Second) AND OS LIKE '%Server%'"

	results = db.query(sql).first

	current_srvroffcount = results['count']


	send_event('srvroffcount', { value: current_srvroffcount } )
db.close
end
