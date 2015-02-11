require "animate"

TPose = {
	root = {name = "root", length = 15, rotation = 0, skin = {file="testskin/torso.png",x=7,y=0}, children = {
			{name = "head", length = 17, rotation = math.rad(-180), skin = {file="testskin/head.png",x=9,y=9,rotation=math.pi,ppx=0,ppy=4}},
			{name = "chestbone1", length = 6, rotation = math.pi/2, at=1/15, children = {
					{name = "left_arm", length = 9, rotation = math.rad(-90), skin = {file="testskin/leftarm.png",x=4,y=0},at = 1},
				}
			},
			{name = "chestbone2", length = 7, rotation = -math.pi/2, at=1/15, before = true, children = {
					{name = "right_arm", length = 8, rotation = math.rad(90), skin = {file="testskin/rightarm.png",x=4,y=0},at = 1},
				}
			},
			{name = "hip1", length = 4, rotation = math.pi/2, at = 1, children = {
					{name = "left_leg", length = 11, rotation = math.rad(-90), skin = {file="testskin/leftleg.png",x=2,y=0}, at = 1},
				}
			},
			{name = "hip2", length = 4, rotation = -math.pi/2, at = 1, children = {
					{name = "right_leg", length = 11, rotation = math.rad(90), skin = {file="testskin/rightleg.png",x=2,y=0}, at = 1},
				}
			},
		}
	},
	animations = {
		raise_arms = {
			{duration = 1, data = {
				left_arm = {rotation = math.rad(-90)},
				--left_arm_lower = {rotation = math.rad(25)},
				right_arm = {rotation = math.rad(90)},
				--right_arm_lower = {rotation = math.rad(-25)}
			}},
			{duration = 1, data = {
				left_arm = {rotation = math.rad(-80)},
				--left_arm_lower = {rotation = math.rad(0)},
				right_arm = {rotation = math.rad(80)},
				--right_arm_lower = {rotation = math.rad(0)}
			}},
		}
	}
}

initPose(TPose)
--startAnimation(TPose, "raise_arms")

icons = setmetatable({},{__index=function(_,i)
	local img = love.graphics.newImage("icons/"..i..".png")
	icons[i] = img
	return img
end,__mode="v"})

function love.load()
	loveframes = require "loveframes"
	loveframes.SetState("edit")
	
	editor = {}
	require "windows.boneframe"
	require "windows.propertyframe"
	require "windows.animationsframe"
end
 
function love.mousepressed(x, y, button)
	loveframes.mousepressed(x, y, button)
end
function love.mousereleased(x, y, button)
	loveframes.mousereleased(x, y, button)
end
function love.keypressed(key, unicode)
	loveframes.keypressed(key, unicode)
end
function love.keyreleased(key)
	loveframes.keyreleased(key)
end
function love.textinput(text)
	loveframes.textinput(text)
end

function love.update(dt)
	updateAnimation(TPose,dt)
	loveframes.update(dt)
end

function love.draw()
	love.graphics.setBackgroundColor(128,128,128)
	love.graphics.push()
	love.graphics.translate(400,300)
	love.graphics.scale(8)
	drawBone(TPose,TPose.root)
	love.graphics.pop()
	--draw animationsframe tweening thing--
	if #animationsframe.tweeningLines > 3 then
		love.graphics.line(animationsframe.tweeningLines)
	end
	loveframes.draw()
end
