-- Narejeno na verziji Löve 0.10.2
m = require "math"
require "auxilliary"
require "generators"

trans = 0
rmin = 40
rmax = 100
dfid = 0.9*m.pi/2
Rfig = 10
Rnpc = 7
numSeg = 20
konec = false
Kbonus = 1.3
Pnpc = 1
Pnpc = 0.75




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
			if diff( x, y, krogi[poz][5][1][1], krogi[poz][5][1][2] ) < Rfig+Rnpc then
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
			love.graphics.circle( "fill", krogi[i][5][1][1], krogi[i][5][1][2], Rnpc, 100 )
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
