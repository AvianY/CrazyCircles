-- Check if the table contains one of the values
function has_value ( table, values)
	for _, vtab in ipairs(table) do
		for _, vvals in ipairs(values) do
			if vtab == vvals then
				return true
			end
		end
	end
	return false
end



-- Check if point (xpos, ypos) is far enough from circles
-- which are listed in "pozs"
function farEnough( t, pozs, point, Kbonus )
	for _,krog in ipairs(pozs) do
		if diffFig( t, krog, point[1], point[2] ) < (t[krog].r) + Kbonus then
			return false
		end
	end
	return true
end

-- Check if point (xpos, ypos) is far enough from points
function farEnough_p2p( points, point, Kbonus )
	if #points > 1 then
		if points[1][1] ~= null then
			for k,pts in ipairs(points) do
				if diff( pts[1], pts[2], point[1], point[2] ) < Kbonus then
					return false
				end
			end
		end
	end
	return true
end

-- razdalja med točkama
function diff(x1, y1, x2, y2)
	return m.sqrt( (x1 - x2)^2 + (y1 - y2)^2 )
end

-- razdalja med dvema krogoma (poz1 in poz2, ki ju najdemo v t)
function difft( t, poz1, poz2 )
	return m.sqrt( (t[poz1].x - t[poz2].x)^2 + (t[poz1].y - t[poz2].y)^2 )
end

-- razdalja med krogom poz, ki je v 't' in splošno x,y pozicijo (namenjeno figurici)
function diffFig( t, poz, xpos, ypos )
	return m.sqrt( (t[poz].x - xpos)^2 + (t[poz].y - ypos)^2 )
end

-- pridobi kot med vodoravnico in daljico, ki gre skozi presečišči sredin
-- dveh krogov, ki ju najdemo v 't'
function avgAngle( t )
	avgPoint = avgKrg( t )
	xlast = t[#t].x
	ylast = t[#t].y
	return m.atan2(  ylast - avgPoint[2] , xlast - avgPoint[1]  )
end

-- pridobi kot med vodoravnico in daljico, ki gre skozi presečišči sredin
-- dveh krogov, ki ju najdemo v 't'
function anglet( t, poz1, poz2 )
	local y1 = t[poz1].y
	local x1 = t[poz1].x
	local y2 = t[poz2].y
	local x2 = t[poz2].x
	return m.atan2(  y2 - y1 , x2 - x1  )
end

function camera_transition( t, last, poz, steps  )
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	local ratio = trans/steps
	if trans <= steps then
		-- najprej odmaknemo pogled od izhodišča do trenutnega kroga,
		-- nato pa vsakič se pomaknemo za večji odmik proti naslednjemu
		love.graphics.translate(-t[last].x + width/2, -t[last].y + height/2)
		love.graphics.translate((-t[poz].x + t[last].x)*ratio, (-t[poz].y + t[last].y)*ratio)
		trans = trans + 1
	else
		--ponastavimo spremenljivke in upoštevamo, da se ob koncu "iteracije"
		--izvede zadnja iteracija, kjer se mora zoper kamera premaknit na
		--pravo mesto in zato moramo še tu postavit primerno tranzlacijo.
		trans = 0
		game.pozChange = false
		love.graphics.translate( -t[poz].x + width/2, -t[poz].y + height/2)
	end
end
