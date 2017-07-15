-- Narejeno na verziji Löve 0.10.2
m = require "math"

-- razdalja med točkama
function diff(x1, y1, x2, y2)
	return m.sqrt( (x1 - x2)^2 + (y1 - y2)^2 )
end

function difft( t, poz1, poz2 )
	return m.sqrt( (t[poz1][1] - t[poz2][1])^2 + (t[poz1][2] - t[poz2][2])^2 )
end

function diffFig( t, poz, xpos, ypos )
	return m.sqrt( (t[poz][1] - xpos)^2 + (t[poz][2] - ypos)^2 )
end

function angle( t, poz1, poz2 )
	y1 = t[poz1][2]
	x1 = t[poz1][1]
	y2 = t[poz2][2]
	x2 = t[poz2][1]
	return m.atan2(  y2 - y1 , x2 - x1  )
end

function genone( t )
	local L = #t
	local preFi = angle( t, L-1 , L)
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

-- Check if the table contains one of the values
local function has_value ( table, values)
	for ktab, vtab in ipairs(table) do
		for kvals, vvals in ipairs(values) do
			if vtab == vvals then
				return true
			end
		end
	end
	return false
end

function camera_transition()
	if trans <= 20 then
		-- najprej odmaknemo pogled od izhodišča do trenutnega kroga,
		-- nato pa vsakič se pomaknemo za večji odmik proti naslednjemu
		love.graphics.translate( -krogi[poz - pozChange][1] + love.graphics.getWidth()/2,
			-krogi[poz - pozChange][2] + love.graphics.getHeight()/2)
		love.graphics.translate(( -krogi[poz][1] + krogi[poz - pozChange][1])*trans/20,
			(-krogi[poz][2] + krogi[poz - pozChange][2])*trans/20)
		trans = trans + 1
	else
		--ponastavimo spremenljivke
		trans = 0
		pozChange = 0
		love.graphics.translate( -krogi[poz][1] + love.graphics.getWidth()/2,
			-krogi[poz][2] + love.graphics.getHeight()/2)
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

	--rmin = najmanjši polmer kroga
	--rmax = največji polmer kroga
	--dfid = največji kotni odmik do naslednje točke
	--numSeg = število krogov
	--konec = preveri ali je konec igre
	rmin = 40
	rmax = 100
	dfid = 0.9*m.pi/2
	numSeg = 10
	konec = false
	Kbonus = 1.3

	trans = 0

	-- krogi = x, y, r

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

	local retries = 0
	for i=3,numSeg do
		::RETRY::
		krogi = genone( krogi )

		-- Check for circle colisions!!
		-- If they colide, remove the last table entry
		for j=1,i-1 do
			if not has_value( krogi[i][4], {j} ) then
			-- if true then
				if difft( krogi, i, j )+10 < krogi[i][3] + krogi[j][3] then
					table.remove(krogi, #krogi)
					retries = retries + 1
					if retries > 2 then
						love.load()
					end
					goto RETRY -- I am so sorry...
				end
			end
		end
	end


	--poz pove v katerem krogu smo
	--pozChange pove, če je prišlo do dogodka, da se spremeni trenutni krog
	--	(1 za naprej, -1 za nazaj)
	--fi je trenutni kot okoli trenutnega kroga
	--Rfig je polmer premikajočega se kroga
	--inside pove ali smo v ali zunaj kroga
	--smer pove v katero smer se vrtimo
	poz = 1
	pozChange = 0
	fi = 0
	Rfig = 10
	inside = 1
	smer = 1

	x = krogi[poz][1] + (krogi[poz][3] - Rfig*inside)*m.cos(fi)
	y = krogi[poz][2] + (krogi[poz][3] - Rfig*inside)*m.sin(fi)

	love.audio.play(zacetek)
end

function love.update( dt )
	if konec == false then
		fi = fi%(2*m.pi) + 2*m.pi/krogi[poz][3]*smer
		if fi > 2*m.pi then
			fi = 0
		end
	end

	x = krogi[poz][1] + (krogi[poz][3] - Rfig*inside)*m.cos(fi)
	y = krogi[poz][2] + (krogi[poz][3] - Rfig*inside)*m.sin(fi)

	if poz == numSeg and konec == false then
		konec = true
		love.audio.play(zmaga)

	elseif poz+1 <= numSeg and diff(x, y, krogi[poz+1][1], krogi[poz+1][2]) < (Rfig + krogi[poz+1][3])
		and konec == false
		and inside == -1 then
		konec = true
		love.audio.play(nalet)

	elseif poz > 1 then
		if diff(x, y, krogi[poz-1][1], krogi[poz-1][2]) < (Rfig + krogi[poz-1][3])
			and konec == false
			and inside == -1 then
			konec = true
			love.audio.play(nalet)
		end

	end

end

function love.draw()
	if konec == false then
		love.graphics.print( poz )
		--naredimo prehodno animacijo za takrat, ko spremenimo krog
		if pozChange ~= 0 then
			camera_transition()
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
		love.graphics.print("Press 'r' to restart", 280, 330)
		love.graphics.print("or 'q' to quit", 300, 360)
		love.graphics.scale( 1/(trans + 1), 1/(trans + 1) )
		trans = trans + 0.01
		love.graphics.translate( -(krogi[poz][1] - krogi[1][1])/2 + love.graphics.getWidth()/2,
			-(krogi[poz][2] - krogi[1][2])/2 + love.graphics.getHeight()/2)

	end

	--Nariše kroge
	for i=1,numSeg do
		love.graphics.setColor( 255, 255, 255)
		love.graphics.circle( "line", krogi[i][1], krogi[i][2], krogi[i][3], 100 )
	end

	love.graphics.setColor(255, 0, 0)
	love.graphics.circle( "fill", x, y, Rfig, 100 )
end

function love.keypressed( key, scancode, isrepeat )
	if scancode == 'q' then
		love.event.quit()
	elseif scancode == "space" and konec == false then
		love.audio.play(preskok)
		for k,v in ipairs(krogi[poz][4]) do -- Check if close enough to neighs
			if diffFig( krogi, v, x, y ) < (krogi[v][3])*Kbonus then
				fi = angle( krogi, poz, v ) + m.pi
				poz = v
				smer = -smer
			else
				inside = -inside
			end
		end
	elseif  scancode == 'r' then
		love.load()
	end
end
