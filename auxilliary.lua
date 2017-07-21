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
		if diffFig( t, krog, point[1], point[2] ) < (t[krog][3]) + Kbonus then
			return false
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
	return m.sqrt( (t[poz1][1] - t[poz2][1])^2 + (t[poz1][2] - t[poz2][2])^2 )
end

-- razdalja med krogom poz, ki je v 't' in splošno x,y pozicijo (namenjeno figurici)
function diffFig( t, poz, xpos, ypos )
	return m.sqrt( (t[poz][1] - xpos)^2 + (t[poz][2] - ypos)^2 )
end

-- pridobi kot med vodoravnico in daljico, ki gre skozi presečišči sredin
-- dveh krogov, ki ju najdemo v 't'
function anglet( t, poz1, poz2 )
	local y1 = t[poz1][2]
	local x1 = t[poz1][1]
	local y2 = t[poz2][2]
	local x2 = t[poz2][1]
	return m.atan2(  y2 - y1 , x2 - x1  )
end

function camera_transition( t, last, poz, steps  )
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	local ratio = trans/steps
	if trans <= steps then
		-- najprej odmaknemo pogled od izhodišča do trenutnega kroga,
		-- nato pa vsakič se pomaknemo za večji odmik proti naslednjemu
		love.graphics.translate(-t[last][1] + width/2, -t[last][2] + height/2)
		love.graphics.translate((-t[poz][1] + t[last][1])*ratio, (-t[poz][2] + t[last][2])*ratio)
		trans = trans + 1
	else
		--ponastavimo spremenljivke in upoštevamo, da se ob koncu "iteracije"
		--izvede zadnja iteracija, kjer se mora zoper kamera premaknit na
		--pravo mesto in zato moramo še tu postavit primerno tranzlacijo.
		trans = 0
		pozChange = false
		love.graphics.translate( -t[poz][1] + width/2, -t[poz][2] + height/2)
	end
end
