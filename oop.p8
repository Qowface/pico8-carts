pico-8 cartridge // http://www.pico-8.com
version 42
__lua__
-- object oriented programming

-- dark blue
pal(0,129,1)

function _init()
	score=0
	
	stars={}
	star_types={
		star,
		far_star,
		near_star
	}
	
	for i=1,50 do
		local star_type=rnd(star_types)
		
		add(stars,star_type:new({
			x=rnd(127),
			y=rnd(127)
		}))
	end
end

function _update()
	for star in all(stars) do
		star:update()
	end
end

function _draw()
	cls()
	
	for star in all(stars) do
		star:draw()
	end
	
	print("score: "..score,8,8,7)
end

-->8
-- class

global=_ENV

class=setmetatable({
	new=function(self,tbl)
		tbl=tbl or {}
		setmetatable(tbl,{
			__index=self
		})
		return tbl
	end,
},{__index=_ENV})

entity=class:new({
	x=0,
	y=0,
})

-->8
-- stars

star=entity:new({
	spd=.5,
	rad=0,
	clr=13,
	
	update=function(_ENV)
		y+=spd
		
		if y-rad>127 then
			y=-rad
			global.score+=1
		end
	end,
	
	draw=function(_ENV)
		circfill(x,y,rad,clr)
	end
})

far_star=star:new({
	clr=1,
	spd=.25,
	rad=0
})

near_star=star:new({
	clr=7,
	spd=.75,
	rad=1,
	
	new=function(self,tbl)
		tbl=star.new(self,tbl)
		
		tbl.spd=tbl.spd+rnd(.5)
		
		return tbl
	end
})

__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
