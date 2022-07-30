pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--shmup

function _init()
	cls(0)
	
	mode="start"
	
	blinkt=1
end

function _update()
	blinkt+=1
	
	if mode=="game" then
		update_game()
	elseif mode=="start" then
		update_start()
	elseif mode=="over" then
		update_over()
	end
end

function _draw()
	if mode=="game" then
		draw_game()
	elseif mode=="start" then
		draw_start()
	elseif mode=="over" then
		draw_over()
	end
end

function startgame()
	mode="game"
	
	ship={}
	ship.x=60 --ship position
	ship.y=60
	ship.sx=2 --ship speed
	ship.sy=2
	ship.spr=2 --ship sprite
	
	flamespr=5 --flame sprite
	
	bulx=60 --bullet position
	buly=-10
	bulspd=4 --bullet speed
	
	muzzle=0 --muzzle flash
	
	score=10000
	
	lives=3
	
	--set up starfield
	stars={}
	for i=1,100 do
		local newstar={}
		newstar.x=flr(rnd(128))
		newstar.y=flr(rnd(128))
		newstar.spd=rnd(1.5)+0.5
		add(stars,newstar)
	end
	
	buls={} --bullets
	
	enemies={}
	
	local myen={}
	myen.x=60
	myen.y=5
	myen.spr=21
	add(enemies,myen)
end

-->8
--tools

function starfield()
	for i=1,#stars do
		local star=stars[i]
		local scol=6
		
		if star.spd<1 then
			scol=1
		elseif star.spd<1.5 then
			scol=13
		end
		
		pset(star.x,star.y,scol)
	end
end

function animatestars()
	for i=1,#stars do
		local star=stars[i]
		star.y+=star.spd
		if (star.y>128) star.y-=128
	end
end

function blink()
	local banim={5,5,5,5,5,5,5,5,5,5,5,6,6,7,7,6,6,5,5}
	if blinkt>#banim then
		blinkt=1
	end
	
	return banim[blinkt]
end

function drwmyspr(myspr)
	spr(myspr.spr,myspr.x,myspr.y)
end

-->8
--update

function update_game()
	local dx=0
	local dy=0
	
	ship.spr=2
	
	if btn(0) then
		dx=-ship.sx
		ship.spr=1
	end
	if btn(1) then
		dx=ship.sx
		ship.spr=3
	end
	if (btn(2)) dy=-ship.sy
	if (btn(3)) dy=ship.sy
	if (btnp(4)) mode="over"
	if btnp(5) then
		local newbul={}
		newbul.x=ship.x
		newbul.y=ship.y-3
		newbul.spr=16
		add(buls,newbul)
		
		sfx(0)
		muzzle=6
	end
	
	--move the ship
	ship.x+=dx
	ship.y+=dy
	
	--move the bullets
	for i=#buls,1,-1 do
		local bul=buls[i]
		bul.y-=bulspd
		
		if (bul.y<-8) del(buls,bul)
	end
	
	--move enemies
	for en in all(enemies) do
		en.y+=1
		en.spr+=0.4
		if (en.spr>=25) en.spr=21
		
		if (en.y>128) del(enemies,en)
	end
	
	--animate flame
	flamespr+=1
	if (flamespr>9) flamespr=5
	
	--animate muzzle flash
	if (muzzle>0) muzzle-=1
	
	--check if we hit the edge
	if ship.x>120 then
		ship.x=0
	elseif ship.x<0 then
		ship.x=120
	end
	
	animatestars()
end

function update_start()
	if btnp(4) or btnp(5) then
		startgame()
	end
end

function update_over()
	if btnp(4) or btnp(5) then
		mode="start"
	end
end

-->8
--draw

function draw_game()
	cls(0)
	
	starfield()
	
	drwmyspr(ship)
	spr(flamespr,ship.x,ship.y+8)
	
	--draw enemies
	for en in all(enemies) do
		drwmyspr(en)
	end
	
	--draw bullets
	for bul in all(buls) do
		drwmyspr(bul)
	end
	
	if muzzle>0 then
		circfill(ship.x+3,ship.y-2,muzzle,7)
	end
	
	print("score:"..score,40,1,12)
	
	for i=1,4 do
		if lives>=i then
			spr(13,i*9-8,1)
		else
			spr(14,i*9-8,1)
		end
	end
end

function draw_start()
	cls(1)
	print("my awesome shmup",34,40,12)
	print("press any key to start",20,80,blink())
end

function draw_over()
	cls(8)
	print("game over",48,40,2)
	print("press any key to continue",18,80,blink())
end

__gfx__
00000000000220000002200000022000000000000000000000000000000000000000000000000000000000000000000000000000088008800880088000000000
000000000028820000288200002882000000000000077000000770000007700000c77c0000077000000000000000000000000000888888888008800800000000
007007000028820000288200002882000000000000c77c000007700000c77c000cccccc000c77c00000000000000000000000000888888888000000800000000
0007700000288e2002e88e2002e882000000000000cccc00000cc00000cccc0000cccc0000cccc00000000000000000000000000888888888000000800000000
00077000027c88202e87c8e202887c2000000000000cc000000cc000000cc00000000000000cc000000000000000000000000000088888800800008000000000
007007000211882028811882028811200000000000000000000cc000000000000000000000000000000000000000000000000000008888000080080000000000
00000000025582200285582002285520000000000000000000000000000000000000000000000000000000000000000000000000000880000008800000000000
00000000002992000029920000299200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900000000000000000000000000000000000330033003300330033003300330033000000000000000000000000000000000000000000000000000000000
09aaaa900000000000000000000000000000000033b33b3333b33b3333b33b3333b33b3300000000000000000000000000000000000000000000000000000000
9aa77aa9000000000000000000000000000000003bbbbbb33bbbbbb33bbbbbb33bbbbbb300000000000000000000000000000000000000000000000000000000
9a7777a9000000000000000000000000000000003b7717b33b7717b33b7717b33b7717b300000000000000000000000000000000000000000000000000000000
9a7777a9000000000000000000000000000000000b7117b00b7117b00b7117b00b7117b000000000000000000000000000000000000000000000000000000000
9aa77aa9000000000000000000000000000000000037730000377300003773000037730000000000000000000000000000000000000000000000000000000000
09aaaa90000000000000000000000000000000000303303003033030030330300303303000000000000000000000000000000000000000000000000000000000
00999900000000000000000000000000000000000300003030000003030000300330033000000000000000000000000000000000000000000000000000000000
__sfx__
000100003a5503755034550325502f5502955026550225501e5501c5501855014550115500d5500a5500a00008000050000300000000000000000000000000000000000000000000000000000000000000000000
