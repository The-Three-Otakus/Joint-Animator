local tween = require "tween"

function iterateBones(pose, func)
	local stack = {}
	local parent = pose.root
	local i = 1
	func(pose.root)
	while parent.children[i] or #stack > 0 do
		if not parent.children[i] then
			parent,i = stack[#stack][1],stack[#stack][2]
			stack[#stack] = nil
		else
			func(parent.children[i],parent)
			if parent.children[i].children and #parent.children[i].children > 0 then
				stack[#stack+1] = {parent,i+1}
				parent = parent.children[i]
				i = 1
			else
				i = i+1
			end
		end
	end
end

function drawBone(pose, bone, parent)
	love.graphics.push()
	love.graphics.translate(0,(parent and parent.length or 0)*(bone.at or 0))
	--love.graphics.print(bone.name,0,0)
	--print(bone.name.." "..bone.rotation)
	love.graphics.rotate(bone.rotation)
	--love.graphics.line(0,0,0,bone.length)
	
	if bone.children then
		for i, v in pairs(bone.children) do
			if v.before then
				drawBone(pose, v, bone)
			end
		end
	end
	
	if bone.skin then
		love.graphics.draw(pose.images[bone.skin.file],bone.skin.ppx or 0,bone.skin.ppy or 0,bone.skin.rotation or 0,1,1,bone.skin.x,bone.skin.y)
	end
	
	if bone.children then
		for i, v in pairs(bone.children) do
			if not v.before then
				drawBone(pose, v, bone)
			end
		end
	end
	love.graphics.pop()
end

function startAnimation(pose, name, rep, durationMultiplier, callback)
	if pose.tween then
		pose.tween:reset()
	end
	local animation = pose.animations[name]
	pose.current = animation
	pose.keyframe = 1
	pose.rep = rep or 1
	pose.durationMultiplier = durationMultiplier or 1
	pose.tween = tween.new((durationMultiplier or 1) * animation[pose.keyframe].duration, pose.bones, animation[pose.keyframe].data, animation[pose.keyframe].easing or "inOutQuad")
	pose.callback = callback
end

function updateAnimation(pose,dt)
	if pose.tween then
		local finished = pose.tween:update(dt)
		if finished then
			pose.keyframe = pose.keyframe+1
			if not pose.current[pose.keyframe] then
				pose.rep = pose.rep-1
				if pose.rep <= 0 then
					pose.tween = nil
					pose.callback()
					return
				else
					pose.keyframe = 1
				end
			end
			pose.tween = tween.new(pose.durationMultiplier * pose.current[pose.keyframe].duration, pose.bones, pose.current[pose.keyframe].data, pose.current[pose.keyframe].easing or "inOutQuad")
		end
	end
end

function setFrame(pose, animation, keyframe)
	local kf = pose.animations[animation][keyframe]
	for i, v in pairs(kf.data) do
		for n, v in pairs(v) do
			print(i,n,v)
			pose.bones[i][n] = v
		end
	end
end

function initPose(pose)
	--fill in the pose--
	pose.bones = {}
	pose.physics = {}
	pose.animations.begin = {{duration = 0, data = {}}}
	pose.images = {}
	iterateBones(pose, function(bone,parent)
		pose.bones[bone.name] = bone
		bone.parent = parent
		pose.animations.begin[1].data[bone.name] = {rotation=bone.rotation or 0,length=bone.length or 0,at=bone.at or 0}
		if bone.skin and not pose.images[bone.skin.file] then
			pose.images[bone.skin.file] = love.graphics.newImage(bone.skin.file)
			pose.images[bone.skin.file]:setFilter("nearest","nearest")
		end
		--[[if bone.physics then
			if pose.world then
				pose.world = pose.world or love.physics.newWorld()
				local s = {}
				--get cumulative rotation--
				local cr = bone.rotation or 0
				local pb = parent
				while pb do
					cr = cr+(pb.rotation or 0)
					pb = pb.parent
				end
				for seg=1, bone.number do
					
				end
				pose.physics[bone.name] = love.physics.newChainShape(false,)
			end
		end]]
	end)
end

local function deepcopy(tab,cache)
	cache = cache or {}
	if cache[tab] then return cache[tab] end
	local nt = {}
	cache[tab] = nt
	for i, v in pairs(tab) do
		if type(v) == "table" then
			nt[i] = deepcopy(v,cache)
		else
			nt[i] = v
		end
	end
	return nt
end

function copyPose(pose)
	--copies a pose for reinitialization--
	local new = deepcopy(pose)
	setFrame(new, "begin", 1) --set the frame to the beginning
	iterateBones(new,function(bone) bone.parent = nil end)
	new.bones = nil
	new.animations.begin = nil
	new.current = nil
	new.keyframe = nil
	new.rep = nil
	new.durationMultiplier = nil
	new.tween = nil
	new.callback = nil
	new.images = nil
	return new
end
