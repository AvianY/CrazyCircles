-- Narejeno na verziji Löve 0.10.2
m = require "math"

-- razdalja med točkama
function diff(x1, y1, x2, y2)
	return m.sqrt( (x1 - x2)^2 + (y1 - y2)^2 )
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
	math.randomseed( os.time() )

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
	--numKrog = število krogov
	--konec = preveri ali je konec igre
	rmin = 40
	rmax = 200
	dfid = 0.3*m.pi/2
	numKrog = 40
	konec = false
	Kbonus = 1.3

	trans = 0

	--krogi = x, y, r
	--d (dist vektor) = fi , R, fid
	krogi = { {300, 300, 100} }
	d = { { 0, 100, 0 } }
	
	--generira kroge
	for i=2,numKrog do
		fid = math.random(-dfid*100, dfid*100)/100
		fi = fid + d[i - 1][1]
		r = math.random(rmin, rmax)
		R = r + d[i - 1][2]

		x = krogi[i - 1][1]+(r + krogi[i - 1][3])*m.cos(fi)
		y = krogi[i - 1][2]+(r + krogi[i - 1][3])*m.sin(fi)
		table.insert(krogi, {x, y, r})
		table.insert(d, { fi, R, fid })
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

	if poz == numKrog and konec == false then
		konec = true
		love.audio.play(zmaga)
		
	elseif poz+1 <= numKrog and diff(x, y, krogi[poz+1][1], krogi[poz+1][2]) < (Rfig + krogi[poz+1][3])
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
		if poz < numKrog then
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
	for i=1,numKrog do
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
		if poz == 1 then
			if inside == 1 and krogi[poz+1][3] + Kbonus*Rfig
				> diff(x, y, krogi[poz+1][1], krogi[poz+1][2]) then
				fi = d[poz][1] + d[poz+1][3] + m.pi
				poz = poz+1
				smer = -smer
				pozChange = 1
			else
				inside = -inside
			end
		else
			if inside == 1 and krogi[poz+1][3] + Kbonus*Rfig
				> diff(x, y, krogi[poz+1][1], krogi[poz+1][2]) then
				fi = d[poz][1] + d[poz+1][3] + m.pi
				poz = poz+1
				smer = -smer
				pozChange = 1
			elseif inside == 1 and krogi[poz-1][3] + Kbonus*Rfig
				> diff(x, y, krogi[poz-1][1], krogi[poz-1][2]) then
				fi = d[poz][1] + d[poz+1][3] + m.pi
				poz = poz-1
				smer = -smer
				pozChange = - 1
			else
				inside = -inside
			end
		end
	elseif scancode == 'r' then
		love.load()
	end
end
