-- Generira kroge za trenutno igro
function generate_circles( t, numseg, starting, retries, exDist )
	for i=starting,numseg do
		t = genone( t )
		-- Check for circle colisions!!
		-- If they colide, remove the last table entry
		for j=1,i-1 do
			-- preveri le za tiste kroge, ki hkrati niso sosedi
			if not has_value( t[i][4], {j} ) then
			-- if true then
				if difft(t, i, j) < t[i][3] + t[j][3]+exDist then
					if retries > 10 then
						for _=1,5 do
							table.remove(t)
						end
						retries = 0
						generate_circles( t, numseg, #t+1, retries, 20 )
						break
					end
					table.remove(t)
					retries = retries + 1
					generate_circles( t, numseg, #t+1, retries, 20 )
					break
				end
			end
		end
	end
end

-- generira enemy-je
function generate_npcs( t, Pnpc, minR )
	local newBonus = 30
	table.insert(t[1], {})
	for i=2,numSeg do
		table.insert(t[i], {})
		if m.random() < Pnpc and
				t[i][3] < minR then
			local inout = m.random(-1, 1)
			if inout <= 0 then
				inout = -1
			else
				inout = 1
			end
			local randFi
			local xpos
			local ypos
			repeat
				 randFi = m.random( -m.pi, m.pi )
				 xpos = t[i][1] + (t[i][3] - Rnpc*inout)*m.cos(randFi)
				 ypos = t[i][2] + (t[i][3] - Rnpc*inout)*m.sin(randFi)
			until farEnough( t, t[i][4], {xpos, ypos}, newBonus )
			table.insert(t[i][5], { xpos, ypos })
		end
	end
	return t
end

-- generira en krog in ga doda v 't'
function genone( t )
	local L = #t
	local preFi = anglet( t, L-1 , L)
	local randFi = m.random( -dfid*100, dfid*100 )/100
	local newFi = preFi + randFi
	local randR = m.random( rmin, rmax )
	local newX = t[L][1] + ( randR + t[L][3] )*m.cos(newFi)
	local newY = t[L][2] + ( randR + t[L][3] )*m.sin(newFi)
	local newCircle = { newX, newY, randR, {L} }

	table.insert(t[L][4], L+1)
	table.insert(t, newCircle)

	return t
end

