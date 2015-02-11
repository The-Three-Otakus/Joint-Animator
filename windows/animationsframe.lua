animationsframe = loveframes.Create("frame")
animationsframe:SetName("Animations")
animationsframe:SetState("edit")
animationsframe:SetPos(love.graphics.getWidth()-animationsframe:GetWidth(),animationsframe:GetHeight())
animationsframe:SetSize(animationsframe:GetWidth(), animationsframe:GetHeight()+120)

editor.keyframe = 1
editor.animation = nil
local canUpdateContent = true

local multichoice = loveframes.Create("multichoice",animationsframe)
multichoice:SetPos(5, 30)
local pfc = false
for i, v in pairs(TPose.animations) do
	if not pfc then editor.animation = i multichoice:SetChoice(i) pfc = true end
	multichoice:AddChoice(i)
end
multichoice:SetSize(animationsframe:GetWidth()-icons.add:getWidth()-15,multichoice:GetHeight())
function multichoice:OnChoiceSelected(choice)
	editor.animation = choice
	editor.keyframe = 1
	animationsframe:updateContent()
end

local add = loveframes.Create("imagebutton",animationsframe)
add:SetPos(multichoice:GetX()+multichoice:GetWidth()+10, 35)
add:SetSize(icons.add:getWidth(),icons.add:getHeight())
add:SetImage(icons.add)
add:SetText("")
function add:OnClick()
	local textdialog = loveframes.Create("frame")
	textdialog:SetSize(300,60)
	textdialog:SetState("edit")
	textdialog:Center()
	textdialog:SetName("Add animation")
	local edit = loveframes.Create("textinput",textdialog)
	edit:SetPos(5,30)
	edit:SetSize(290,25)
	textdialog:SetModal(true)
	
	function edit:OnEnter()
		textdialog:Remove()
		local ani = edit:GetText()
		if TPose.animations[ani] then return end
		TPose.animations[ani] = {{duration=1,data={}}}
		editor.keyframe = 1
		animationsframe:updateContent()
	end
end

local prevkeyframe = loveframes.Create("button",animationsframe)
prevkeyframe:SetText("Previous")
prevkeyframe:SetPos(5, multichoice:GetHeight()+35)
function prevkeyframe:OnClick()
	if editor.keyframe > 1 then
		editor.keyframe = editor.keyframe-1
		animationsframe:updateContent()
	end
end

local nextkeyframe = loveframes.Create("button",animationsframe)
nextkeyframe:SetText("Next")
nextkeyframe:SetPos(animationsframe:GetWidth()-nextkeyframe:GetWidth()-5, multichoice:GetHeight()+35)
function nextkeyframe:OnClick()
	if editor.keyframe < #TPose.animations[editor.animation] then
		editor.keyframe = editor.keyframe+1
		animationsframe:updateContent()
	end
end

local numberbox = loveframes.Create("numberbox",animationsframe)
numberbox:SetPos(nextkeyframe:GetWidth()+10, multichoice:GetHeight()+35)
numberbox:SetSize(animationsframe:GetWidth()-nextkeyframe:GetWidth()-prevkeyframe:GetWidth()-20,prevkeyframe:GetHeight())
function numberbox:OnValueChanged()
	editor.keyframe = numberbox:GetValue()
	animationsframe:updateContent()
end

local duration = loveframes.Create("numberbox",animationsframe)
duration:SetPos(5, nextkeyframe:GetHeight()+multichoice:GetHeight()+40)
duration:SetSize(animationsframe:GetWidth()-10,25)
function duration:OnValueChanged()
	TPose.animations[editor.animation][editor.keyframe].duration = duration:GetValue()
end

local tweening = loveframes.Create("multichoice",animationsframe)
animationsframe.tweening = tweening
animationsframe.tweeningTween = nil
animationsframe.tweeningLines = {}
tweening:SetPos(5, nextkeyframe:GetHeight()*2+multichoice:GetHeight()+45)
tweening:SetSize(animationsframe:GetWidth()-10,25)
for i, v in pairs(require "tween".easing) do
	tweening:AddChoice(i)
end
function tweening:OnChoiceSelected()
	local choice = tweening:GetValue()
	TPose.animations[editor.animation][editor.keyframe].easing = choice
	animationsframe.tweeningLines = {}
	animationsframe.tweenSubject = {love.graphics.getHeight()*(3/4)}
	animationsframe.tweeningTween = require "tween".new(1,animationsframe.tweenSubject,{love.graphics.getHeight(),},choice)
end
function tweening:Update(dt)
	if animationsframe.tweeningTween then
		local finish = animationsframe.tweeningTween:update(dt)
		if finish then
			animationsframe.tweeningTween = nil
			return
		end
		local tf = love.graphics.getWidth()*(1/4)
		animationsframe.tweeningLines[#animationsframe.tweeningLines+1] = love.graphics.getWidth()*(3/4)+(animationsframe.tweeningTween.clock*tf)
		animationsframe.tweeningLines[#animationsframe.tweeningLines+1] = animationsframe.tweenSubject[1]
	end
end
tweening:SetChoice("inOutQuad")
tweening:OnChoiceSelected()
tweening:Sort()

local addkeyframe = loveframes.Create("button",animationsframe)
addkeyframe:SetText("Add Keyframe")
addkeyframe:SetPos(5, nextkeyframe:GetHeight()*3+multichoice:GetHeight()+50)
addkeyframe:SetSize(animationsframe:GetWidth()-10,addkeyframe:GetHeight())
function addkeyframe:OnClick()
	TPose.animations[editor.animation][editor.keyframe+1] = {duration=1,data={}}
	editor.keyframe = editor.keyframe+1
	animationsframe:updateContent()
end

local play = loveframes.Create("button",animationsframe)
play:SetText("Play")
play:SetPos(5, nextkeyframe:GetHeight()*4+multichoice:GetHeight()+55)
play:SetSize(animationsframe:GetWidth()-10,play:GetHeight())
function play:OnClick()
	setFrame(TPose,"begin",1)
	startAnimation(TPose, editor.animation, nil, nil, function()
		loveframes.SetState("edit")
		animationsframe:updateContent()
	end)
	loveframes.SetState("playback")
end

local load = loveframes.Create("button",animationsframe)
load:SetText("Load")
load:SetPos(5, nextkeyframe:GetHeight()*5+multichoice:GetHeight()+60)
load:SetSize(animationsframe:GetWidth()-10,25)
function load:OnClick()
	local textdialog = loveframes.Create("frame")
	textdialog:SetSize(300,60)
	textdialog:SetState("edit")
	textdialog:Center()
	textdialog:SetName("Load")
	local edit = loveframes.Create("textinput",textdialog)
	edit:SetPos(5,30)
	edit:SetSize(290,25)
	textdialog:SetModal(true)
	
	function edit:OnEnter()
		TPose = require "Tserial".unpack(love.filesystem.read(edit:GetText()..".lua"))
		initPose(TPose)
		editor.keyframe = 1
		animationsframe:updateContent()
		textdialog:Remove()
	end
end

local save = loveframes.Create("button",animationsframe)
save:SetText("Save")
save:SetPos(5, nextkeyframe:GetHeight()*6+multichoice:GetHeight()+65)
save:SetSize(animationsframe:GetWidth()-10,25)
function save:OnClick()
	local textdialog = loveframes.Create("frame")
	textdialog:SetSize(300,60)
	textdialog:SetState("edit")
	textdialog:Center()
	textdialog:SetName("Save As...")
	local edit = loveframes.Create("textinput",textdialog)
	edit:SetPos(5,30)
	edit:SetSize(290,25)
	textdialog:SetModal(true)
	
	function edit:OnEnter()
		local copy = copyPose(TPose)
		local sc = require "Tserial".pack(copy)
		love.filesystem.write(edit:GetText()..".lua",sc)
		textdialog:Remove()
	end
end

function animationsframe:updateContent()
	if not canUpdateContent then return end
	canUpdateContent = false
	
	local pfc = false
	multichoice:Clear()
	local cn = editor.animation
	for i, v in pairs(TPose.animations) do
		if not pfc then editor.animation = i multichoice:SetChoice(i) pfc = true end
		if i == cn then
			editor.animation = cn
			multichoice:SetChoice(cn)
			pfc = true
		end
		multichoice:AddChoice(i)
	end
	
	numberbox:SetValue(editor.keyframe)
	duration:SetValue(TPose.animations[editor.animation][editor.keyframe].duration)
	setFrame(TPose,"begin",1)
	for i=1, editor.keyframe do
		setFrame(TPose,editor.animation,i)
	end
	boneframe.tree:OnSelectNode()
	canUpdateContent = true
end

animationsframe:updateContent()
