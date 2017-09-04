function init()
	trans = 0

	game = { 
		konec = false,
		poz = 1,
		last = 1,
		pozChange = false,
		fi = 0,
		inside = 1,
		smer = 1,
		random = true,
		score = 0
	}

	krg = {
		rmin = 60,
		rmax = 100,
		dfid = 0.9*m.pi/2,
		Pnpc = 0.75,
		Rnpc = 7,
		Ppnt = 0.6,
		Rpnt = 5,
		Rfig = 10,
		Kbonus = 20
	}

	--Zvočni efekti
	preskok = love.audio.newSource("audio/sfx_movement_jump14.wav", "static")
	nalet = love.audio.newSource("audio/sfx_exp_shortest_hard5.wav", "static")
	zmaga = love.audio.newSource("audio/sfx_sounds_button7.wav", "static")
	zacetek = love.audio.newSource("audio/sfx_sounds_button14.wav", "static")
	tocke = love.audio.newSource("audio/sfx_coin_double1.wav", "static")
	
	m.randomseed( os.time() )

	font = love.graphics.newFont(20) -- the number denotes the font size
	love.graphics.setFont(font)

	--generira prvi in drugi krog
	table.insert( krg, { x = 300, y = 300, r = 92, ngs = {2}, npcs = {}, pts = {} })

	local randFi = m.random( -100*m.pi, 100*m.pi)/100
	local randR = m.random( krg.rmin, krg.rmax )
	sekX = krg[1].x + (randR + krg[1].r)*m.cos(randFi)
	sekY = krg[1].y + (randR + krg[1].r)*m.sin(randFi)
	table.insert( krg, { x = sekX, y = sekY, r = randR, ngs = {1}, npcs = {}, pts = {} })

	generate_circles1( krg, numKrog, 20)

	krg = generate_points( krg, 80)
	krg = generate_npcs( krg, 70)

	x = krg[game.poz].x + (krg[game.poz].r - krg.Rfig*game.inside)*m.cos(game.fi)
	y = krg[game.poz].y + (krg[game.poz].r - krg.Rfig*game.inside)*m.sin(game.fi)

	love.audio.play(zacetek)
	
end
