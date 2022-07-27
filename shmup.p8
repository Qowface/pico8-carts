pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--shmup

function _init()
	shipx=60 --ship position
	shipy=60
	shipsx=2 --ship speed
	shipsy=2
	shipspr=2 --ship sprite
	
	flamespr=5 --flame sprite
	
	bulx=60 --bullet position
	buly=-10
	bulspd=4 --bullet speed
	
	muzzle=0 --muzzle flash
	
	score=10000
	
	lives=3
	
	starx={}
	stary={}
	starspd={}
	for i=1,100 do
		add(starx,flr(rnd(128)))
		add(stary,flr(rnd(128)))
		add(starspd,rnd(1.5)+0.5)
	end
end

function _update()
	dx=0
	dy=0
	shipspr=2
	
	if btn(0) then
		dx=-shipsx
		shipspr=1
	end
	if btn(1) then
		dx=shipsx
		shipspr=3
	end
	if (btn(2)) dy=-shipsy
	if (btn(3)) dy=shipsy
	if btnp(5) then
		bulx=shipx
		buly=shipy-3
		sfx(0)
		muzzle=6
	end
	
	--move the ship
	shipx+=dx
	shipy+=dy
	
	--move the bullet
	buly-=bulspd
	
	--animate flame
	flamespr+=1
	if (flamespr>9) flamespr=5
	
	--animate muzzle flash
	if (muzzle>0) muzzle-=1
	
	--check if we hit the edge
	if shipx>120 then
		shipx=0
	elseif shipx<0 then
		shipx=120
	end
	
	animatestars()
end

function _draw()
	cls(0)
	
	starfield()
	
	spr(shipspr,shipx,shipy)
	spr(flamespr,shipx,shipy+8)
	
	spr(16,bulx,buly)
	
	if muzzle>0 then
		circfill(shipx+3,shipy-2,muzzle,7)
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

-->8
function starfield()
	for i=1,#starx do
		local scol=6
		if starspd[i]<1 then
			scol=1
		elseif starspd[i]<1.5 then
			scol=13
		end
		pset(starx[i],stary[i],scol)
	end
end

function animatestars()
	for i=1,#stary do
		local sy=stary[i]
		sy+=starspd[i]
		if (sy>128) sy-=128
		stary[i]=sy
	end
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
00999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaa90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aa77aa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9a7777a9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9a7777a9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
9aa77aa9000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
09aaaa90000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00999900000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000100003a5503755034550325502f5502955026550225501e5501c5501855014550115500d5500a5500a00008000050000300000000000000000000000000000000000000000000000000000000000000000000
