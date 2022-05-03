
-- Turbo Wieszcz++ version in LUA for Playdate console, v1.0
-- (c)2022 Noniewicz.com, Jakub Noniewicz aha MoNsTeR/GDC
-- cre: 20220502
-- upd: 20220503

--[[ TODO:
# LATER:
1. PL chars proper?
2. msx 2 mp3 - some issue - WTF?
3. some anims?
]]

import 'CoreLibs/graphics'
import 'turbowieszcz'

local gfx = playdate.graphics
local screenWidth = playdate.display.getWidth()
local screenHeight = playdate.display.getHeight()
playdate.display.setRefreshRate(25)

local s, ms = playdate.getSecondsSinceEpoch()
math.randomseed(ms, s)
local msx_on = true
local cnt = 8 -- start with 8 for nice crank scroll
local powt = false
local rym = 0
local mode = 0
local angle = 0
local menu_item = 0
local poem = ""

local font = gfx.font.new('assets/Asheville-Rounded-24-px') -- header
local font2 = gfx.font.new('assets/Roobert-10-Bold') -- small things
local font3 = gfx.font.new('assets/Sasser-Slab-Bold') -- menu
local font4 = gfx.font.new('assets/font-Cuberick-Bold') -- main poem + about
local logo = gfx.image.new('assets/startscreen-400x240')
local bg = gfx.image.new('assets/bg-400x240')

music = playdate.sound.sampleplayer.new('assets/twzx')
music:setVolume(1)
music:play(0)

gfx.setColor(gfx.kColorWhite)
gfx.fillRect(0, 0, screenWidth, screenHeight)
gfx.setBackgroundColor(gfx.kColorWhite)
gfx.setColor(gfx.kColorBlack)

-- update

function menuitem(title, state, y)
	gfx.setColor(gfx.kColorBlack)
	gfx.drawRoundRect(100-10, y-8, 220, 30, 16)
	if state then
		gfx.drawRoundRect(100-10+1, y-8+1, 220-2, 30-2, 16)
		gfx.drawRoundRect(100-10+2, y-8+2, 220-4, 30-4, 16)
	end
	gfx.drawText(title, 100, y)
end

function generate()
	angle = 0
	poem = generate_poem(cnt, rym, powt)

	-- need to kill PL chars for now
	poem = string.gsub(poem, "ą", "a")
	poem = string.gsub(poem, "ę", "e")
	poem = string.gsub(poem, "ć", "c")
	poem = string.gsub(poem, "ń", "n")
	poem = string.gsub(poem, "ś", "s")
	poem = string.gsub(poem, "ó", "o")
	poem = string.gsub(poem, "ł", "l")
	poem = string.gsub(poem, "ź", "z")
	poem = string.gsub(poem, "ż", "z")

	poem = string.gsub(poem, "Ą", "A")
	poem = string.gsub(poem, "Ę", "E")
	poem = string.gsub(poem, "Ć", "C")
	poem = string.gsub(poem, "Ń", "N")
	poem = string.gsub(poem, "Ś", "S")
	poem = string.gsub(poem, "Ó", "O")
	poem = string.gsub(poem, "Ł", "L")
	poem = string.gsub(poem, "Ź", "Z")
	poem = string.gsub(poem, "Ż", "Z")
end

function playdate.update()
	gfx.setColor(gfx.kColorWhite)
	gfx.fillRect(0, 0, screenWidth, screenHeight)
	gfx.setBackgroundColor(gfx.kColorWhite)
	gfx.setColor(gfx.kColorBlack)

	if mode == 0 then -- title screen
		logo:draw(0, 0)
		gfx.setColor(gfx.kColorBlack)
		gfx.setFont(font)
		gfx.drawText('Turbo\nWieszcz++', 4, 2)
		gfx.setFont(font2)
		gfx.drawText('v1.0, build: 20220503\nFreeware!', 4, 66)
		gfx.drawText('(c)2022 Noniewicz.com', 4, 240-20)
		if playdate.buttonJustPressed("B") or playdate.buttonJustPressed("A") then
			mode = 1
			return
		end
	end
	if mode == 1 then -- menu
		bg:draw(0, 0)
		gfx.setColor(gfx.kColorBlack)
		gfx.setFont(font)
		gfx.drawText('Turbo Wieszcz++', 4, 2)
		gfx.setFont(font3)
		menuitem('NOWY WIERSZ', menu_item==0, 45+32*0)
		menuitem('ILE ZWROTEK: '..cnt, menu_item==1, 45+32*1)
		if powt then
			menuitem('POWTORZENIA: TAK', menu_item==2, 45+32*2)
		else
			menuitem('POWTORZENIA: NIE', menu_item==2, 45+32*2)
		end
		local srym = ""
		if rym == 0 then srym = 'ABAB' end
		if rym == 1 then srym = 'ABBA' end
		if rym == 2 then srym = 'AABB' end
		menuitem('RYM: '..srym, menu_item==3, 45+32*3)
		if msx_on then
			menuitem('MUZYKA: TAK', menu_item==4, 45+32*4)
		else
			menuitem('MUZYKA: NIE', menu_item==4, 45+32*4)
		end
		menuitem('O PROGRAMIE', menu_item==5, 45+32*5)
		if playdate.buttonJustPressed("UP") and menu_item > 0 then
			menu_item = menu_item - 1
		end
		if playdate.buttonJustPressed("DOWN") and menu_item < 5 then
			menu_item = menu_item + 1
		end
		if playdate.buttonJustPressed("RIGHT") or playdate.buttonJustPressed("A") then
			if menu_item == 0 then
				mode = 2
				generate()
				return
			end
			if menu_item == 1 and cnt < 32 then cnt = cnt + 1 end
			if menu_item == 2 then powt = not powt end
			if menu_item == 3 then rym = rym + 1 if rym > 2 then rym = 0 end end
			if menu_item == 4 then msx_on = not msx_on if msx_on then music:play(0) else music:stop() end end
			if menu_item == 5 then mode = 3 angle = 0 return end
		end
		if playdate.buttonJustPressed("LEFT") or playdate.buttonJustPressed("B") then
			if menu_item == 0 then
				mode = 2
				generate()
				return
			end
			if menu_item == 1 and cnt > 1 then cnt = cnt - 1 end
			if menu_item == 2 then powt = not powt end
			if menu_item == 3 then rym = rym - 1 if rym < 0 then rym = 2 end end
			if menu_item == 4 then msx_on = not msx_on if msx_on then music:play(0) else music:stop() end end
		end
	end
	if mode == 2 then -- poem
		local size = 15*(3+5*cnt)-(15*5) -- total poem height in pixels
		local change = playdate.getCrankChange()
		if change ~= 0 then
			angle += change
			if angle < 0 then angle = 0 end
			if angle > size then angle = size end
		end
		bg:draw(0, 0)
		gfx.setFont(font4)
		gfx.drawText(poem, 8, -angle)

		if playdate.buttonJustPressed("B") then
			mode = 1
		end
		if playdate.buttonJustPressed("A") then
			generate()
		end
	end
	if mode == 3 then -- about
		local size = 15*(21-4) -- total txt height in pixels
		local change = playdate.getCrankChange()
		if change ~= 0 then
			angle += change
			if angle < 0 then angle = 0 end
			if angle > size then angle = size end
		end
		bg:draw(0, 0)
		gfx.setColor(gfx.kColorBlack)
		gfx.setFont(font)
		gfx.drawText('Turbo Wieszcz++', 4, 2-angle)
		gfx.setFont(font4)
		local s =
"Generator poezji (FREEWARE), wersja w LUA na Playdate\
\
(c)2022 Noniewicz.com, Jakub Noniewicz aka MoNsTeR/GDC\
http://www.noniewicz.com/\
Dodatkowe strofy (c):\
Grych, Freeak, Monster, Fred i Marek Pampuch.\
Muzyka:\
V0yager (wersja z ZX Spectrum).\
\
Oparty na poprzedniej wersji napisanej w Python-ie\
opartej z kolei na pomysle zaprezentowanym w czasopismie\
\"Magazyn Amiga\" autorstwa Marka Pampucha.\
\
Zainspirowany rowniez wersja napisana na iPhone-a\
przez Tomka (Grycha) Gryszkiewicza.\
\
Historia programu opisana w magazynie Ha!art 47 3/2014\
\
Inne wersje (stan na maj 2022):\
- Commodore C-64\
- Android\
- ZX Spectrum\
- Python\
- Fortran\
- ZX81\
- Amstrad CPC\
- Arduino\
- Windows / Raspberry PI / Linux / Windows CE\
- Octave / Matlab\
- LUA"

		gfx.drawText(s, 4, 40-angle)
		if playdate.buttonJustPressed("B") then
			mode = 1
		end
	end
end
