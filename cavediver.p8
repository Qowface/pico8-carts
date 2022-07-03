pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
function _init()
	game_over=false
	make_cave()
	make_player()
end

function _update()
	if (not game_over) then
		update_cave()
		move_player()
		check_hit()
	else
		if (btnp(5)) _init() --restart
	end
end

function _draw()
	cls()
	draw_cave()
	draw_player()
	
	if (game_over) then
		print("game over!",44,44,7)
		print("your score:"..player.score,34,54,7)
		print("press ❎ to play again!",18,72,6)
	else
		print("score:"..player.score,2,2,7)
	end		
end

-->8
function make_player()
	player={}
	player.x=24
	player.y=60
	player.dy=0
	player.rise=1
	player.fall=2
	player.dead=3
	player.speed=2
	player.score=0
end

function move_player()
	gravity=0.2
	player.dy+=gravity
	
	--jump
	if (btnp(2)) then
		player.dy-=5
		sfx(0)
	end
	
	--move to new position
	player.y+=player.dy
	
	--update score
	player.score+=player.speed
end

function check_hit()
	for i=player.x,player.x+7 do
		if (cave[i+1].top>player.y
			or cave[i+1].btm<player.y+7) then
			game_over=true
			sfx(1)
		end
	end
end

function draw_player()
	if (game_over) then
		spr(player.dead,player.x,player.y)
	elseif (player.dy<0) then
		spr(player.rise,player.x,player.y)
	else
		spr(player.fall,player.x,player.y)
	end
end

-->8
function make_cave()
	cave={{["top"]=5,["btm"]=119}}
	top=45 --lowest ceiling can go
	btm=85 --highest floor can go
end

function update_cave()
	--remove back of cave
	if (#cave>player.speed) then
		for i=1,player.speed do
			del(cave,cave[1])
		end
	end
	
	--add more cave
	while (#cave<128) do
		local col={}
		local up=flr(rnd(7)-3)
		local dwn=flr(rnd(7)-3)
		col.top=mid(3,cave[#cave].top+up,top)
		col.btm=mid(btm,cave[#cave].btm+dwn,124)
		add(cave,col)
	end
end

function draw_cave()
	top_color=5
	btm_color=5
	for i=1,#cave do
		line(i-1,0,i-1,cave[i].top,top_color)
		line(i-1,127,i-1,cave[i].btm,btm_color)
	end
end

__gfx__
0000000000aaaa0000aaaa0000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa00aaaaaa008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700aa1aa1aaaaaaaaaa88988988000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aaaaaaaaaa1aa1aa88888888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000aa1111aaaaaaaaaa88899888000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700aaa11aaaaaa11aaa88988988000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000aaaaaa00aa11aa008888880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000aaaa0000aaaa0000888800000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000400000c0500e050000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000a00003205000000290500000022050000000604006030060300603006020060200602006010060100601000000000000000000000000000000000000000000000000000000000000000000000000000000000
