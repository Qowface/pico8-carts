pico-8 cartridge // http://www.pico-8.com
version 36
__lua__
--squashy

function _init()
	init_paddle()
	init_ball()
	score=0
	lives=3
end

function _update()
	update_paddle()
	update_ball()
end

function _draw()
	cls(3)
	draw_paddle()
	draw_ball()
	draw_ui()
end

-->8
--paddle

function init_paddle()
	p={}
	p.x=52
	p.y=122
	p.w=24
	p.h=4
end

function update_paddle()
	movepaddle()
end

function movepaddle()
	if btn(0) then
		p.x-=3
	elseif btn(1) then
		p.x+=3
	end
end

function draw_paddle()
	rectfill(p.x,p.y,p.x+p.w,p.y+p.h,15)
end

-->8
--ball

function init_ball()
	b={}
	b.x=64
	b.y=64
	b.size=3
	b.xdir=5
	b.ydir=-3
end

function update_ball()
	moveball()
	bounceball()
	losedeadball()
end

function moveball()
	b.x+=b.xdir
	b.y+=b.ydir
end

function bounceball()
	--left/right
	if b.x<b.size or b.x>128-b.size then
		b.xdir=-b.xdir
		sfx(0)
	end
	--top
	if b.y<b.size then
		b.ydir=-b.ydir
		sfx(0)
	end
	--paddle
	if b.x>=p.x and
			b.x<=p.x+p.w and
			b.y>p.y-p.h then
		b.ydir=-b.ydir
		sfx(0)
		score+=10
	end
end

function losedeadball()
	if b.y>128-b.size then
		if lives>0 then
			--next life
			sfx(3)
			b.y=24
			lives-=1
		else
			--game over
			b.xdir=0
			b.ydir=0
			b.y=64
		end
	end
end

function draw_ball()
	circfill(b.x,b.y,b.size,15)
end

-->8
--ui

function draw_ui()
	--score
	print(score,12,6,15)
	
	--lives
	for i=1,lives do
		spr(4,90+i*8,4)
	end
end

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000000000000000000000000000ff0ff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000fffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000fffffff00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000770000000000000000000000000000fffff000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0070070000000000000000000000000000fff0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000f00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
000400003805000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
001000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00060000240501d05017050130500f0500c0500c00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000