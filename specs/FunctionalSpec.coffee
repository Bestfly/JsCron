{jscron} = require '../'

describe "JsCron",->

	describe "input format validation",->
		it "allows just numbers",->
			expect(jscron._findOptions("1 1 1 1 1 1")).toEqual([[1],[1],[1],[1],[1],[1]])
		it "allows astrisks",->
			expect(jscron._findOptions("* * * * * *")).toEqual([[0..59],[0..59],[0..23],[1..31],[1..12],[0..6]])
		it "allows steps",->
			expect(jscron._findOptions("*/10 */5 */3 */12 */5 */2")).toEqual([[0,10,20,30,40,50],[0,5,10,15,20,25,30,35,40,45,50,55],[0,3,6,9,12,15,18,21],[1,13,25],[1,6,11],[0,2,4,6]])

		it "allows steps with ranges",->
			expect(jscron._findOptions("0-10/10 0-10/5 0-10/3 1-10/12 1-10/5 0-4/2")).toEqual([[0,10],[0,5,10],[0,3,6,9],[1],[1,6],[0,2,4]])
		it "allows comma delimited preset values",->
			expect(jscron._findOptions("1,2 3,4 5,6 7,8 9,10 1,4")).toEqual([[1,2],[3,4],[5,6],[7,8],[9,10],[1,4]])

	describe "poking with a stick",->

		it "parses 'every second' directive in cron format and return valid results for a full hour",->
			cron = "* * * * * *"
			startTime = Date.now()
			endTime = Date.now() + ( 60 * 60 * 1000 )
			res = jscron.parse(cron, startTime, endTime) 	
			expect(res.length).toEqual( 60 * 60 )

		it "ignores a date range that is outside of allowed month",->
			cron = "0 0 0 1 1 *"
			startTime = Date.parse("Feb 1, 2012")
			endTime = Date.parse("March 1, 2012")
			res = jscron.parse(cron, startTime, endTime)
			expect(res.length).toEqual(0)


		it "returns date ranges per hour",->
			cron = "0 0 * * * *"
			startTime = Date.parse("01:00 Feb 1, 2012")
			endTime = Date.parse("01:00 Feb 2, 2012")
			res = jscron.parse(cron, startTime, endTime)
			expect(res.length).toEqual(24)


		it "handles the days correctly",->
			cron = "0 0 0 1 * *"
			startTime = Date.parse("Jan 1, 2000")
			endTime = Date.parse("Jan 1, 2012")
			expect(jscron.parse(cron,startTime, endTime).length).toEqual(12*12)

		it "handles months correctly",->
			cron = "0 0 0 1 1 *"
			startTime = Date.parse("Jan 1, 2000")
			endTime = Date.parse("Jan 1, 2012")
			expect(jscron.parse(cron,startTime, endTime).length).toEqual(12)

		it "handles days of week correctly",->
			cron = "0 0 0 * * 0"
			startTime = Date.parse("Oct 1, 2012")
			endTime = Date.parse("Oct 31, 2012")
			expect(jscron.parse(cron,startTime, endTime).length).toEqual(4)

