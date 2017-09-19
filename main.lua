-- Narejeno na verziji Löve 0.10.2
m = require "math"
require "init"
require "auxilliary"
require "generators"
local o_ten_one = require "o-ten-one"

numKrog = 30

function love.load()
	splash = o_ten_one()
	splash.onDone = function() print "DONE" end
	init()
end

function love.update( dt )
	splash:update(dt)
	if game.konec == false then
		game.fi = game.fi%(2*m.pi) + 2*m.pi/krg[game.poz].r*game.smer*(2/3)
		if game.fi > 2*m.pi then
			game.fi = 0
		end
	end

	x = krg[game.poz].x + (krg[game.poz].r - krg.Rfig*game.inside)*m.cos(game.fi)
	y = krg[game.poz].y + (krg[game.poz].r - krg.Rfig*game.inside)*m.sin(game.fi)

	if game.poz == #krg and game.konec == false then
		game.konec = true
		love.audio.play(zmaga)

	elseif game.inside == -1 and game.konec == false then
		-- Check if close enough to neigh in general
		for k,neigh in ipairs(krg[game.poz].ngs) do
			if diffFig( krg, neigh, x, y ) < krg[neigh].r then
				game.konec = true
				love.audio.play(nalet)
			end
		end
	end
	if game.konec == false then
		if #krg[game.poz].npcs > 0 then
			if diff( x, y, krg[game.poz].npcs[1].x, krg[game.poz].npcs[1].y ) < krg.Rfig+krg.Rnpc then
				game.konec = true
				love.audio.play(nalet)
			end
		end
	end

	if game.konec == false then
		if #krg[game.poz].pts > 0 then
			for nj=1,#krg[game.poz].pts do
				if krg[game.poz].pts[nj] ~= nil then
					if diff( x, y, krg[game.poz].pts[nj].x, krg[game.poz].pts[nj].y ) < krg.Rfig + krg.Rpnt then
						table.remove(krg[game.poz].pts, nj)
						love.audio.stop(tocke)
						love.audio.play(tocke)
						game.score = game.score + 10
					end
				end
			end
		end
	end

end

function love.draw()
	splash:draw()
	if game.konec == false then
		love.graphics.print( game.poz )
		love.graphics.print( "Score: "..game.score, 0, 20 )
		--naredimo prehodno animacijo za takrat, ko spremenimo krog
		if game.pozChange then
			camera_transition( krg, game.last, game.poz, 20 )
		else
			love.graphics.translate( -krg[game.poz].x + love.graphics.getWidth()/2,
				-krg[game.poz].y + love.graphics.getHeight()/2)
		end
	else
		if game.poz < #krg then
			love.graphics.setColor( 255, 0, 0)
			love.graphics.print("GAME OVER", 300, 300)
		else
			love.graphics.setColor( 0, 255, 0)
			love.graphics.print("YOU WIN", 300, 300)
		end
		love.graphics.print("Press 'r' to retry", 280, 330)
		love.graphics.print("Press 'n' to start a new track", 280, 360)
		love.graphics.print("Press 'q' to quit", 280, 390)
		love.graphics.scale( 1/(trans + 1), 1/(trans + 1) )
		love.graphics.translate( -(krg[game.poz].x - krg[1].x)/2 + love.graphics.getWidth()/2*(trans+1),
			-(krg[game.poz].y - krg[1].y)/2 + love.graphics.getHeight()/2*(trans+1))
		if trans < 20 then
			trans = trans + 0.01
		end
	end

	--Nariše kroge in npcje
	for i=1,#krg do
		love.graphics.setColor( 255, 255, 255)
		love.graphics.circle( "line", krg[i].x, krg[i].y, krg[i].r, 100 )
		if #krg[i].npcs > 0 then
			love.graphics.setColor( 0, 0, 255)
			love.graphics.circle( "fill", krg[i].npcs[1].x, krg[i].npcs[1].y, krg.Rnpc, 100 )
		end
		if #krg[i].pts > 0 then
			love.graphics.setColor( 0, 255, 0)
			for j=1,#krg[i].pts do
				if krg[i].pts[j] ~= nil then
					love.graphics.circle( "fill", krg[i].pts[j].x, krg[i].pts[j].y, krg.Rpnt, 100 )
				end
			end
		end
	end

	love.graphics.setColor(255, 0, 0)
	love.graphics.circle( "fill", x, y, krg.Rfig, 100 )
end

function love.keypressed( key, scancode, isrepeat )
	splash:skip()
	if scancode == 'q' then
		love.event.quit()
	elseif scancode == "space" and game.konec == false then
		love.audio.stop(preskok)
		love.audio.play(preskok)
		-- Check if close enough to neigh upon jumping
		local lock = false
		for _,neigh in ipairs(krg[game.poz].ngs) do
			if diffFig( krg, neigh, x, y ) < krg[neigh].r + krg.Kbonus then -- m.min( krg[neigh].r, krg[game.poz].r)
				game.fi = anglet( krg, game.poz, neigh ) + m.pi
				game.last = game.poz
				game.poz = neigh
				game.pozChange = true
				game.smer = -game.smer
				lock = true
				break
			end
		end
		if not lock then
			game.inside = -game.inside
		end
	elseif  scancode == 'n' then
		trans = 0
		init()
	elseif  scancode == 'r' then
		trans = 0
		game.smer = 1
		game.inside = 1
		game.poz = 1
		game.last = 1
		game.konec = false
		love.audio.play(zacetek)
	end
end
