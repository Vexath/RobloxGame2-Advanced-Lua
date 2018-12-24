return function(timeStamp)
		-- Easy, fast, and working nicely
		local function numberWithZero(num)
			return (num < 10 and "0" or "") .. num
		end
		local string_format = string.format -- optimization
		
		local localTime = timeStamp - os.time() + math.floor(tick())
		local dayTime = localTime % 86400
				
		local hour = math.floor(dayTime/3600)
		
		dayTime = dayTime - (hour * 3600)
		local minute = math.floor(dayTime/60)
		
		dayTime = dayTime - (minute * 60)
		local second = dayTime

		local h = numberWithZero(hour)
		local m = numberWithZero(minute)
		local s = numberWithZero(dayTime)

		return string_format("%s:%s:%s", h, m, s)
end