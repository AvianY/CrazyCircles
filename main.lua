-- Narejeno na verziji Löve 0.10.2
m = require "math"

trans = 0
rmin = 40
rmax = 100
dfid = 0.9*m.pi/2
Rfig = 10
numSeg = 20
konec = false
Kbonus = 1.3
Pnpc = 1
Pnpc = 0.75



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
			repeat
				local randFi = m.random( -m.pi, m.pi )
				local xpos = t[i][1] + (krogi[i][3] - Rfig*inout)*m.cos(randFi)
				local ypos = t[i][2] + (krogi[i][3] - Rfig*inout)*m.sin(randFi)
				local newBonus = 1.5
			until tooCloseCirc( t, t[i][4], {xpos, ypos}, newBonus )
			table.insert(t[i][5], { xpos, ypos })
		end
	end
	return t
end

function tooCloseCirc( t, pozs, point, Kbonus )
	for _,krog in ipairs(pozs) do
		if diffFig( t, krog, point[1], point[2] ) < (t[krog][3])*Kbonus then
			return true
		end
	end
	return false
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

function love.load()
	m.randomseed( os.time() )

	--Zvočni efekti
	preskok = love.audio.newSource("audio/sfx_movement_jump14.wav", "static")
	nalet = love.audio.newSource("audio/sfx_exp_shortest_hard5.wav", "static")
	zmaga = love.audio.newSource("audio/sfx_sounds_button7.wav", "static")
	zacetek = love.audio.newSource("audio/sfx_sounds_button14.wav", "static")

	--lepi fonti
	-- font = love.graphics.newImageFont("Imagefont.png",
    -- " abcdefghijklmnopqrstuvwxyz" ..
    -- "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    -- "123456789.,!?-+/():;%&`'*#=[]\"")
	font = love.graphics.newFont(20) -- the number denotes the font size
	love.graphics.setFont(font)

	--generira prvi in drugi krog
	krogi = { {300, 300, m.random( rmin, rmax ), {2}} }

	local randFi = m.random( -100*m.pi, 100*m.pi)/100
	local randR = m.random( rmin, rmax )
	sekX = krogi[1][1] + (randR + krogi[1][3])*m.cos(randFi)
	sekY = krogi[1][2] + (randR + krogi[1][3])*m.sin(randFi)
	table.insert( krogi, { sekX, sekY, randR, {1} })

	--generira kroge
	local Pone = 1
	local Pfour = 0

	generate_circles( krogi, numSeg, 3, 0, 20)

	-- generate_npcs( t, Pnpc )
	-- t = tabela krogov
	-- Pnpc = verjetnost, da bo v nekem krogu npc

	krogi = generate_npcs( krogi, Pnpc, 70)


	--poz pove v katerem krogu smo
	--last pove kateri je bil tazadnji krog v kateremu smo bili
	--pozChange pove, če je prišlo do dogodka, da se spremeni trenutni krog
	--	(1 za naprej, -1 za nazaj)
	--fi je trenutni kot okoli trenutnega kroga
	--Rfig je polmer premikajočega se kroga
	--inside pove ali smo v ali zunaj kroga
	--smer pove v katero smer se vrtimo
	poz = 1
	last = 1
	pozChange = false
	fi = 0
	inside = 1
	smer = 1

	x = krogi[poz][1] + (krogi[poz][3] - Rfig*inside)*m.cos(fi)
	y = krogi[poz][2] + (krogi[poz][3] - Rfig*inside)*m.sin(fi)

	love.audio.play(zacetek)
end

function love.update( dt )
	if konec == false then
		fi = fi%(2*m.pi) + 2*m.pi/krogi[poz][3]*smer*(2/3)
		if fi > 2*m.pi then
			fi = 0
		end
	end

	x = krogi[poz][1] + (krogi[poz][3] - Rfig*inside)*m.cos(fi)
	y = krogi[poz][2] + (krogi[poz][3] - Rfig*inside)*m.sin(fi)

	if poz == numSeg and konec == false then
		konec = true
		love.audio.play(zmaga)

	elseif inside == -1 and konec == false then
		 -- Check if close enough to neigh in general
		for k,neigh in ipairs(krogi[poz][4]) do
			if diffFig( krogi, neigh, x, y ) < krogi[neigh][3] then
				konec = true
				love.audio.play(nalet)
			end
		end
	end
	if konec == false then
		if #krogi[poz][5] > 0 then
			if diff( x, y, krogi[poz][5][1][1], krogi[poz][5][1][2] ) < 2*Rfig then
				konec = true
				love.audio.play(nalet)
			end
		end
	end

end

function love.draw()
	if konec == false then
		love.graphics.print( poz )
		--naredimo prehodno animacijo za takrat, ko spremenimo krog
		if pozChange then
			camera_transition( krogi, last, poz, 20 )
		else
			love.graphics.translate( -krogi[poz][1] + love.graphics.getWidth()/2,
				-krogi[poz][2] + love.graphics.getHeight()/2)
		end
	else
		if poz < numSeg then
			love.graphics.print("GAME OVER", 300, 300)
		else
			love.graphics.setColor( 0, 255, 0)
			love.graphics.print("YOU WIN", 300, 300)
		end
		love.graphics.print("Press 'r' to retry", 280, 330)
		love.graphics.print("Press 'n' to start a new track", 280, 360)
		love.graphics.print("or 'q' to quit", 300, 380)
		love.graphics.scale( 1/(trans + 1), 1/(trans + 1) )
		love.graphics.translate( -(krogi[poz][1] - krogi[1][1])/2 + love.graphics.getWidth()/2*(trans+1),
			-(krogi[poz][2] - krogi[1][2])/2 + love.graphics.getHeight()/2*(trans+1))
		if trans < 20 then
			trans = trans + 0.01
		end
	end

	--Nariše kroge in npcje
	for i=1,numSeg do
		love.graphics.setColor( 255, 255, 255)
		love.graphics.circle( "line", krogi[i][1], krogi[i][2], krogi[i][3], 100 )
		if #krogi[i][5] > 0 then
			love.graphics.setColor( 0, 0, 255)
			love.graphics.circle( "fill", krogi[i][5][1][1], krogi[i][5][1][2], Rfig, 100 )
		end
	end

	love.graphics.setColor(255, 0, 0)
	love.graphics.circle( "fill", x, y, Rfig, 100 )
end

function love.keypressed( key, scancode, isrepeat )
	if scancode == 'q' then
		love.event.quit()
	elseif scancode == "space" and konec == false then
		love.audio.play(preskok)
		 -- Check if close enough to neigh upon jumping
		local lock = false
		for k,neigh in ipairs(krogi[poz][4]) do
			if diffFig( krogi, neigh, x, y ) < (krogi[neigh][3])*Kbonus then
				fi = anglet( krogi, poz, neigh ) + m.pi
				last = poz
				poz = neigh
				pozChange = true
				smer = -smer
				lock = true 
				break
			end
		end
		if not lock then
			inside = -inside
		end
	elseif  scancode == 'n' then
		konec = false
		love.load()
	elseif  scancode == 'r' then
		poz = 1
		konec = false
		inside = 1
		love.audio.play(zacetek)
	end
end
