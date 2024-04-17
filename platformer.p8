pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
--platformer

function _init()
	player={
		sp=1, --sprite #
		x=59, --x position
		y=59, --y position
		w=8, --width
		h=8, --height
		flp=false, --flip sprite?
		dx=0, --delta x
		dy=0, --delta y
		max_dx=2, --limit dx
		max_dy=3, --limit dy
		acc=0.5, --acceleration
		boost=4, --jump force
		anim=0, --animation timing
		running=false, --movement status
		jumping=false, --""
		falling=false, --""
		sliding=false, --""
		landed=false --""
	}
	
	gravity=0.3 --fall speed
	friction=0.85 --slow x movement
	
	--simple camera
	cam_x=0
	
	--map limits
	map_start=0
	map_end=1024
	
	--test--
	x1r,y1r,x2r,y2r=0,0,0,0
	collide_l="no"
	collide_r="no"
	collide_u="no"
	collide_d="no"
	--------
end

-->8
--update and draw

function _update()
	player_update()
	player_animate()
	
	--simple camera
	cam_x=player.x-64+(player.w/2)
	if cam_x<map_start then
		cam_x=map_start
	end
	if cam_x>map_end-128 then
		cam_x=map_end-128
	end
	camera(cam_x,0)
end

function _draw()
	cls()
	map(0,0)
	spr(player.sp,player.x,player.y,1,1,player.flp)
	
	--test--
	--[[
	rect(x1r,y1r,x2r,y2r,7)
	print("⬅️= "..collide_l,player.x,player.y-10)
	print("➡️= "..collide_r,player.x,player.y-16)
	print("⬆️= "..collide_u,player.x,player.y-22)
	print("⬇️= "..collide_d,player.x,player.y-28)
	]]
	--------
end

-->8
--collisions

function collide_map(obj,aim,flag)
	--obj = table, needs x,y,w,h
	--aim = left,right,up,down
	
	local x,y=obj.x,obj.y
	local w,h=obj.w,obj.h
	local x1,y1,x2,y2=0,0,0,0
	
	if aim=="left" then
		x1=x-1
		y1=y
		x2=x
		y2=y+h-1
	elseif aim=="right" then
		x1=x+w-1
		y1=y
		x2=x+w
		y2=y+h-1
	elseif aim=="up" then
		x1=x+2
		y1=y-1
		x2=x+w-3
		y2=y
	elseif aim=="down" then
		x1=x+2
		y1=y+h
		x2=x+w-3
		y2=y+h
	end
	
	--test--
	x1r,y1r,x2r,y2r=x1,y1,x2,y2
	--------
	
	--pixels to tiles
	x1/=8
	y1/=8
	x2/=8
	y2/=8
	
	if fget(mget(x1,y1), flag)
	or fget(mget(x1,y2), flag)
	or fget(mget(x2,y1), flag)
	or fget(mget(x2,y2), flag)
	then
		return true
	else
		return false
	end
end

-->8
--player

function player_update()
	if collide_map(player,"down",2) then
		--sand = flag 2
		friction=0.50
		player.boost=2
	elseif collide_map(player,"down",3) then
		--ice = flag 3
		friction=0.95
		player.max_dx=3
	else
		--default
		friction=0.85
		player.max_dx=2
		player.boost=4
	end
	
	--physics
	player.dy+=gravity
	player.dx*=friction
	
	--controls
	if btn(⬅️) then
		player.dx-=player.acc
		player.running=true
		player.flp=true
	end
	if btn(➡️) then
		player.dx+=player.acc
		player.running=true
		player.flp=false
	end
	
	--slide
	if player.running
	and not btn(⬅️)
	and not btn(➡️)
	and not player.falling
	and not player.jumping
	then
		player.running=false
		player.sliding=true
	end
	
	--jump
	if btnp(❎)
	and player.landed then
		player.dy-=player.boost
		player.landed=false
	end
	
	--check y collision
	if player.dy>0 then
		player.falling=true
		player.landed=false
		player.jumping=false
		
		player.dy=limit_speed(player.dy,player.max_dy)
		
		if collide_map(player,"down",0) then
			player.landed=true
			player.falling=false
			player.dy=0
			player.y-=((player.y+player.h+1)%8)-1
			
			--test--
			collide_d="yes"
			else collide_d="no"
			--------
		end
	elseif player.dy<0 then
		player.jumping=true
		if collide_map(player,"up",1) then
			player.dy=0
			
			--test--
			collide_u="yes"
			else collide_u="no"
			--------
		end
	end
	
	--check x collision
	if player.dx<0 then
		player.dx=limit_speed(player.dx,player.max_dx)
		
		if collide_map(player,"left",1) then
			player.dx=0
			
			--test--
			collide_l="yes"
			else collide_l="no"
			--------
		end
	elseif player.dx>0 then
		player.dx=limit_speed(player.dx,player.max_dx)
		
		if collide_map(player,"right",1) then
			player.dx=0
			
			--test--
			collide_r="yes"
			else collide_r="no"
			--------
		end
	end
	
	--stop sliding
	if player.sliding then
		if abs(player.dx)<.2
		or player.running then
			player.dx=0
			player.sliding=false
		end
	end
	
	player.x+=player.dx
	player.y+=player.dy
	
	if player.x<map_start then
		player.x=map_start
	end
	if player.x>map_end-player.w then
		player.x=map_end-player.w
	end
end

function player_animate()
	if player.jumping then
		player.sp=7
	elseif player.falling then
		player.sp=8
	elseif player.sliding then
		player.sp=9
	elseif player.running then
		if time()-player.anim>.1 then
			player.anim=time()
			player.sp+=1
			if player.sp>6 then
				player.sp=3
			end
		end
	else --player idle
		if time()-player.anim>.3 then
			player.anim=time()
			player.sp+=1
			if player.sp>2 then
				player.sp=1
			end
		end
	end
end

function limit_speed(num,maximum)
	return mid(-maximum,num,maximum)
end

__gfx__
0000000000444440004444400004444400044444000444440004444400044444c004444400000000000000000000000000000000000000000000000000000000
0000000000ccccc000ccccc00ccccccc0c0cccccc00cccccc0cccccc00cccccc0ccccccc04444400000000000000000000000000000000000000000000000000
007007000cf72f200cf72f20c00ff72fc0cff72f0ccff72f0c0ff72f0c0ff72f000ff72f0ccccc00000000000000000000000000000000000000000000000000
000770000cfffff00cfffef0000ffffe000ffffe000ffffe000ffffec00ffffe000ffffecf72f200000000000000000000000000000000000000000000000000
00077000000cc00000cccc000fccc0000fccc0000fccc0000fccc00000ccc0000000ccc0cfffef00000000000000000000000000000000000000000000000000
0070070000cccc000f0cc0f0000cc000000cc000000cc000000cc0000f0cc0000000cc0f00ccccf0000000000000000000000000000000000000000000000000
000000000f0cd0f0000cd0000cc0d00000cd00000dd0c00000dc000000dc000000000cd00f0ccd00000000000000000000000000000000000000000000000000
0000000000c00d0000c00d000000d00000cd00000000c00000dc00000dc00000000000cd0000ccdd000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb00bbbbbbbbbbbb00f999999f99999999c6cccccccc6ccccc000000000000000000000000000000000000000000000000
3bbb3bbbbbbb3bbb3b333bb3bbbbb33b0bbbb3b3bbb3bbb09ff99ff9f99999ff6cccc6ccc6cccc6c000000000000000000000000000000000000000000000000
33b333b33bb33bbb33443b3433bbb343bb3b34343b3433bb999ff9999ff9ff99cccc6ccc6cccc6cc000000000000000000000000000000000000000000000000
4b3444343bb343b3444443b443bb3444bbb33444434443bbf999999ff99f99ffccc6cccccccccccc000000000000000000000000000000000000000000000000
4b3424443b344434494443b4443b3444bb3444444449443b9f99f9f99f999f997ccccc777ccccc77000000000000000000000000000000000000000000000000
434444444344494444444b3444434424b344444d444443bb49ff9f9449fff99477ccc77777ccc774000000000000000000000000000000000000000000000000
44444d44444444444445434449444444bb34f4444544443b44999944449999444777777444777744000000000000000000000000000000000000000000000000
4944444444d444f4444444444444e444334444444444444344444444444444444477444444444444000000000000000000000000000000000000000000000000
444444444444444444444444444444440000000000000000bbb9999ff9999bbbbb66cc6ccc6cc66b000000000000000000000000000000000000000000000000
4444445446444444444445444444449400000000000000003b339ff99ff933b33b37c6ccc6cc7773000000000000000000000000000000000000000000000000
444494444444224444f4444444f444440000000000000000434449999994443443477cccccc77434000000000000000000000000000000000000000000000000
4444444444442e24444444444444474400000000000000004444499ff9944444444477cccc774444000000000000000000000000000000000000000000000000
4f444444444442244d6644444e44477400000000000000004e4444f99f4444444e44477c77744444000000000000000000000000000000000000000000000000
44444644444444444d66649444447644000000000000000044444444444444d444444477744444d4000000000000000000000000000000000000000000000000
444444444494444444ddd4444477644400000000000000004464444444e444444464444444e44444000000000000000000000000000000000000000000000000
4e44444444444444444444444447444400000000000000004444d444444444444444d44444444444000000000000000000000000000000000000000000000000
33333333333333334444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbbb3bbbbbbbb3bb9999499999999499000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bbb3bbbbbbbb3bbb9994999999994999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333334444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
b3bbbb3bb3bbbbbb9499994994999999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
bb3bbb3bbb3bbbbb9949994999499999000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
33333333333333334444444444444444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300000000000049940000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0033b300003bb3000044940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003333000049940000444400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003b3300003bb3000049440000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
003bb300003bb3000049940000499400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000003030303030307070b0b00000000000003030303000007070b0b0000000000000101010100000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
7170000000000000000000000000000000000000000000000000000000000000000000000060616000000000000000000000000000000000000000000000000060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071000000000000000000000000000000000000000000000000000000000000000000000071007100000000000000000000000000000000000000000000006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7070000000000000000000000000000000000000000000000000000000000000000000000060616000000000000000000000000000000000000000000000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7170000000000000000000000000000000000000000000000000000000000000000000000071007100000000000000000000000000000000000000000060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7071000000000000000000000000000000000000000000000000000000000000000000000060616000000000000000000000000000000000000000006060000000000000000000000000000000000000000000000000000000000000000000000000000044404040404500000000000000000000000000000000000000000000
7071000000000000000000000000000000000000000000000000000000000000000000000071007100000000000000000000000000000000000000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7171000000000000000000000000000000000000000000000000000000000000000000000060616000000000000000000000000000000000000060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
7170000000000000000000000000000000000000000000000000000000000000000000000071007100000000000000000000000000000000006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000444040404500000000000000000000000000000000000000000000
7171000000000000000060000000000000000000000000000000000000000000000000000060616000000000000000000000000000000000606000000000000000000000000000000000000000000000000000000000000000000000000000000000000000505050505045000000000000000000000000000000000000000000
7170000000000000000071000000000000000000000000000000000000000000000000000071007100000000000000000000000000000060600000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000050505050404500000000000000000000000000000000000000
7070006262000000616061606100000000000000000000000000000000000000000000000060616000000000000000000000000000006060000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000005050505000000000000000000000000000000000000000
7171007372000000007000710000000000000000000000000000000000000000000000000071007100000000000060600000000000606000000000000000606000616100006161000000616161006060000000006161000000000061610060600000000000000000000000000000606000000000000000000000000000006060
7170004445000000007100700000000000000000000000000000000000000000000000000060616000000000000071710000000060600000000000000000717100000000000000000000000000007171000000000000000000000000000071710000000000000000000000000000717100000000000000000000000000007171
7071445350434500007000710000000000000000000000000000000000000000000000000071007100000000000071710000006060000000000000000000717100000000000000000000000000007171000000000000000000000000000071710000000000000000000000000000717100000000000000000000000000007171
4043505050515042404140424341425646474647464746574042584849484948494859434140434041404240404143404241404341404340414042404041434042414043414043404140424040414340424140434140434041404240404143404241404341404340414042404041434042414043414043404140424040414340
5050515050525050535050515050525050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050505050
