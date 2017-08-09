-- Generira kroge za trenutno igro
function generate_circles( t, numseg, starting, retries, exDist )
	local i = starting
	while i <= numseg do
		if m.random() < 0.9 then
			g = 1
		else
			g = 4
		end
		if g == 1 then
			t = genone( t )
		else
			if numseg - i > 4 then
				t = genfour( t )
				i = i + 3
			else
				t = genone( t )
			end
		end
		-- Check for circle colisions!!
		-- If they colide, remove the last table entry
		for j=1,i-1 do
			-- preveri le za tiste kroge, ki hkrati niso sosedi
			if not has_value( t[i].ngs, {j} ) then
			-- if true then
				if difft(t, i, j) < t[i].r + t[j].r+exDist then
					if retries > 10 then
						for _=1,5 do
							table.remove(t)
						end
						retries = 0
						i = i - 5
						break
					end
					if g == 1 then
						table.remove(t)
						i = i - 1
					else
						for _=1,4 do
							table.remove(t)
						end
						i = i - 4
						retries = retries + 1
					end
					break
				end
			end
		end
		i = i + 1 
	end
end

-- Drugi poskus generacije krogov.
-- Kriteriji:
--	-Brez rekurzije
--	-Brez while loopa
--	-For loop zazeljeno predstavlja stevilo krogov
--	-Brez preverjanja kolizij med generiranjem.
function generate_circles1( t, numKrog, exDist )
	local i = 2
	while i <= numKrog do
		if m.random() < 0.8 then
			t = genone_col( t, exDist )
			i = i + 1
		else
			t = genthree_col( t, exDist )
			i = i + 3
		end
		if i ~= (#t) then
			print(i, #t)
		end
	end
end

-- generira enemy-je
function generate_npcs( t, minR )
	local distToKrg = 50
	local distToPts = 20
	for i=2,#t do
		if m.random() < t.Pnpc and
				t[i].r > minR then
			local inout = m.random(-1, 2)
			if inout <= 0 then
				inout = -1
			else
				inout = 1
			end
			local randFi
			local xpos
			local ypos
			local trials = 0
			repeat
				randFi = m.random( -m.pi, m.pi )
				xpos = t[i].x + (t[i].r - t.Rnpc*inout)*m.cos(randFi)
				ypos = t[i].y + (t[i].r - t.Rnpc*inout)*m.sin(randFi)
				trials = trials + 1
				if trials > 10 then
					return t
				end
			until farEnough( t, t[i].ngs, {xpos, ypos}, distToKrg )
					and farEnough_p2p( t[i].pts, {xpos, ypos}, distToPts )
			table.insert(t[i].npcs, { x = xpos, y = ypos })
		end
	end
	return t
end

-- generira točke
function generate_points(t, minR)
	local pBonus = 50
	for i=2,#t do
		-- table.remove( t[i].pts )
		if m.random() < t.Ppnt then
			local inout = m.random()
			if inout <= 0.5 or t[i].r < minR then
				inout = 1
			else
				inout = -1
			end
			local numOfPoints = m.random(1,5)
			local randFi
			local xpos
			local ypos
			local trials = 0

			-- Poisce eno tocko, ki je dovolj oddaljena
			repeat
				randFi = m.random()*2*m.pi
				xpos = t[i].x + (t[i].r - t.Rpnt*inout)*m.cos(randFi)
				ypos = t[i].y + (t[i].r - t.Rpnt*inout)*m.sin(randFi)
				trials = trials + 1
				if trials > 10 then
					return t
				end
			until farEnough( t, t[i].ngs, {xpos, ypos}, pBonus ) or inout == 1
			table.insert(t[i].pts, { x = xpos, y = ypos })

			-- Kotni razmak med tockami (eksperimentalno dolocen)
			-- delimo z r-jem, da bodo tocke absolutno enako razmaknjene
			-- na vseh krogih
			deltaFi = m.pi*7/t[i].r

			-- Generiramo se preostale tocke z enakomernim razmakom
			if numOfPoints > 1 then
				for j=1,(numOfPoints - 1) do
					xpos = t[i].x + (t[i].r - t.Rpnt*inout)*m.cos(randFi+deltaFi*j)
					ypos = t[i].y + (t[i].r - t.Rpnt*inout)*m.sin(randFi+deltaFi*j)
					if farEnough( t, t[i].ngs, {xpos, ypos}, pBonus ) or inout == 1 then
						table.insert(t[i].pts, { x = xpos, y = ypos })
					end
				end
			end
		end
	end
	return t
end

-- generira en krog in ga doda v 't'
function genone( t )
	local preFi = anglet( t, #t-1 , #t)
	local randFi = m.random( -krg.dfid*100, krg.dfid*100 )/100
	local newFi = preFi + randFi
	local randR = m.random( krg.rmin, krg.rmax )
	local newX = t[#t].x + ( randR + t[#t].r )*m.cos(newFi)
	local newY = t[#t].y + ( randR + t[#t].r )*m.sin(newFi)
	local newCircle = { x = newX, y = newY, r = randR, ngs = {#t}, npcs = {}, pts = {} }

	table.insert(t[#t].ngs, #t+1)
	table.insert(t, newCircle)

	return t
end

-- generira en krog in ga doda v 't'. Če se križa z drugimi krogi, bo
-- poskusil še enkrat. Krog bo generiral glede na povprečje ostalih
-- krogov.
function genone_col( t, exDist)
	local newCircle
	repeat
		local avgFi = avgAngle( t )
		local randFi = m.random( -krg.dfid*100, krg.dfid*100 )/100
		local newFi = avgFi + randFi
		local randR = m.random( krg.rmin, krg.rmax )
		local newX = t[#t].x + ( randR + t[#t].r )*m.cos(newFi)
		local newY = t[#t].y + ( randR + t[#t].r )*m.sin(newFi)
		newCircle = { x = newX, y = newY, r = randR, ngs = {#t}, npcs = {}, pts = {} }
	until checkCollisions( t , {{ x = newCircle.x, y = newCircle.y, r = newCircle.r}}, exDist  )

	table.insert(t[#t].ngs, #t+1)
	table.insert(t, newCircle)

	return t
end

-- generira 4 kroge in jih doda v 't'. Če se križajo z drugimi krogi, bo
-- poskusil še enkrat. Kroge bo generiral glede na povprečje ostalih
-- krogov.
function genthree_col( t, exDist)
	
	local newCircle1
	local newCircle2
	local newCircle3

	repeat
		local avgFi = avgAngle( t )
		local preR = t[#t].r
		-- Iz nakljucnega ter prejsnjega R-ja izracunamo fi
		local randR = m.random( krg.rmin, krg.rmax )
		local clusFi = m.asin( randR / ( randR + preR) )
		local randn = m.random(1,2)
		if randn == 2 then
			-- kroga v clusterju se ne stikata
			local randkot = m.random(10, 30) / 100
			clusFi = clusFi + randkot
		end
		local clus1X = t[#t].x + ( randR + preR )*m.cos(avgFi + clusFi)
		local clus1Y = t[#t].y + ( randR + preR )*m.sin(avgFi + clusFi)

		local clus2X = t[#t].x + ( randR + preR )*m.cos(avgFi - clusFi)
		local clus2Y = t[#t].y + ( randR + preR )*m.sin(avgFi - clusFi)

		-- nakljucen R za zakljucitveni krog za gruco (cluster)
		local randR1 = m.random( krg.rmin, krg.rmax )

		local height1, height2
		if randn == 1 then
			height1 = m.sqrt( (preR + randR)^2 - (randR)^2 )
			height2 = m.sqrt( (randR1 + randR)^2 - (randR)^2 )
		else
			local extRandR = m.sin(clusFi)*(randR + preR)
			height1 = m.sqrt( (preR + randR)^2 - (extRandR)^2 )
			height2 = m.sqrt( (randR1 + randR)^2 - (extRandR)^2 )
		end
		
		local zakkrg1X = t[#t].x + ( height1 + height2 )*m.cos(avgFi)
		local zakkrg1Y = t[#t].y + ( height1 + height2 )*m.sin(avgFi)
		
		newCircle1 = { x = clus1X, y = clus1Y, r = randR, ngs = {#t, #t+2, #t+3}, npcs = {}, pts = {} }
		newCircle2 = { x = clus2X, y = clus2Y, r = randR, ngs = {#t, #t+1, #t+3}, npcs = {}, pts = {} }
		newCircle3 = { x = zakkrg1X, y = zakkrg1Y, r = randR1, ngs = {#t+1, #t+2 }, npcs = {}, pts = {} }

	until checkCollisions( t , {{ x = newCircle1.x, y = newCircle1.y, r = newCircle1.r},
			       	{ x = newCircle2.x, y = newCircle2.y, r = newCircle2.r},
			       	{ x = newCircle3.x, y = newCircle3.y, r = newCircle3.r} }, exDist  )

	table.insert(t[#t].ngs, #t+1)
	table.insert(t[#t].ngs, #t+2)

	table.insert(t, newCircle1)
	table.insert(t, newCircle2)
	table.insert(t, newCircle3)

	return t
end

-- generira cluster štirih krogov
function genfour( t )
	local preFi = anglet( t, #t-1 , #t)
	local preR = t[#t].r
	-- Iz nakljucnega ter prejsnjega R-ja izracunamo fi
	local randR = m.random( krg.rmin, krg.rmax )
	local clusFi = m.asin( randR / ( randR + preR) )
	local randn = m.random(1,2)
	if randn == 2 then
		-- kroga v clusterju se ne stikata
		local randkot = m.random(10, 30) / 100
		clusFi = clusFi + randkot
	end
	local clus1X = t[#t].x + ( randR + preR )*m.cos(preFi + clusFi)
	local clus1Y = t[#t].y + ( randR + preR )*m.sin(preFi + clusFi)

	local clus2X = t[#t].x + ( randR + preR )*m.cos(preFi - clusFi)
	local clus2Y = t[#t].y + ( randR + preR )*m.sin(preFi - clusFi)

	-- nakljucen R za zakljucitveni krog za gruco (cluster)
	local randR1 = m.random( krg.rmin, krg.rmax )

	local height1, height2
	if randn == 1 then
		height1 = m.sqrt( (preR + randR)^2 - (randR)^2 )
		height2 = m.sqrt( (randR1 + randR)^2 - (randR)^2 )
	else
		local extRandR = m.sin(clusFi)*(randR + preR)
		height1 = m.sqrt( (preR + randR)^2 - (extRandR)^2 )
		height2 = m.sqrt( (randR1 + randR)^2 - (extRandR)^2 )
	end
	
	local zakkrg1X = t[#t].x + ( height1 + height2 )*m.cos(preFi)
	local zakkrg1Y = t[#t].y + ( height1 + height2 )*m.sin(preFi)
	
	-- nakljucen R za zakljucitveni krog celotne stvari (cluster)
	local randR2 = m.random( krg.rmin, krg.rmax )
	local randFi2 = m.random( -krg.dfid/2*100, krg.dfid/2*100 )/100
	local zakkrg2X = zakkrg1X + ( randR1 + randR2 )*m.cos(preFi + randFi2)
	local zakkrg2Y = zakkrg1Y + ( randR1 + randR2 )*m.sin(preFi + randFi2)

	local newCircle1 = { x = clus1X, y = clus1Y, r = randR, ngs = {#t, #t+2, #t+3}, npcs = {}, pts = {} }
	local newCircle2 = { x = clus2X, y = clus2Y, r = randR, ngs = {#t, #t+1, #t+3}, npcs = {}, pts = {} }
	local newCircle3 = { x = zakkrg1X, y = zakkrg1Y, r = randR1, ngs = {#t+1, #t+2 , #t+4}, npcs = {}, pts = {} }
	local newCircle4 = { x = zakkrg2X, y = zakkrg2Y, r = randR2, ngs = { #t+3 }, npcs = {}, pts = {} }

	table.insert(t[#t].ngs, #t+1)
	table.insert(t[#t].ngs, #t+2)

	table.insert(t, newCircle1)
	table.insert(t, newCircle2)
	table.insert(t, newCircle3)
	table.insert(t, newCircle4)

	return t
end

-- dobi povprečno točko nahajanja krogov
function avgKrg( t )
	sumx = 0
	sumy = 0
	for k,v in ipairs(t) do
		sumx = sumx + v.x
		sumy = sumy + v.y
	end
	return { sumx/#t, sumy/#t }
end


-- Preveri kolizijo zadnjih #points krogov z ostalimi krogi
function checkCollisions( t, points, exDist )
	for i=1,#t-1 do
		for j=1,#points do
			if diffFig(t, i, points[j].x, points[j].y) < t[i].r + points[j].r + exDist then
				return false
			end
		end
	end
	return true
end
