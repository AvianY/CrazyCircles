trans = 0

game = { 
	konec = false,
	poz = 1,
	last = 1,
	pozChange = false,
	fi = 0,
	inside = 1,
	smer = 1,
	random = true
}

krg = {
	rmin = 60,
	rmax = 100,
	dfid = 0.9*m.pi/2,
	numKrg = 20,
	Pnpc = 0.75,
	Rnpc = 7,
	Rfig = 10,
	Kbonus = 1.3
}

--Zvočni efekti
preskok = love.audio.newSource("audio/sfx_movement_jump14.wav", "static")
nalet = love.audio.newSource("audio/sfx_exp_shortest_hard5.wav", "static")
zmaga = love.audio.newSource("audio/sfx_sounds_button7.wav", "static")
zacetek = love.audio.newSource("audio/sfx_sounds_button14.wav", "static")
