local parents
boneframe = loveframes.Create("frame")
boneframe:SetName("Bones")
boneframe:SetState("edit")
boneframe:SetSize(boneframe:GetWidth(),boneframe:GetHeight()+30)
local tree = loveframes.Create("tree", boneframe)
boneframe.tree = tree
tree:SetPos(5, 30)
tree:SetSize(boneframe:GetWidth()-10,boneframe:GetHeight()-65)
function boneframe:refreshTree()
	local wasopen = {}
	if parents and parents[TPose.root] then
		for i, v in pairs(parents) do
			wasopen[i] = v:GetOpen()
		end
		parents[TPose.root]:Remove()
	end
	parents = {}
	parents[TPose.root] = tree:AddNode("root")
	parents[TPose.root].bone = TPose.root
	parents[TPose.root]:SetOpen(wasopen[TPose.root])
	iterateBones(TPose, function(bone,parent)
		if parent ~= nil then
			parents[bone] = parents[parent]:AddNode(bone.name)
			parents[bone].bone = bone
			parents[bone]:SetOpen(wasopen[bone])
		end
	end)
end
boneframe:refreshTree()
boneframe.selected = nil
function tree:OnSelectNode(node)
	node = node or parents[boneframe.selected] or parents[TPose.root]
	propertyframe.columnlist:Clear()
	propertyframe.columnlist:AddRow("name",node.bone.name)
	propertyframe.columnlist:AddRow("length",node.bone.length)
	propertyframe.columnlist:AddRow("rotation",math.deg(node.bone.rotation))
	if node.bone.parent then
		propertyframe.columnlist:AddRow("at", node.bone.at or 0)
	end
	boneframe.selected = node.bone
end

local new = loveframes.Create("button", boneframe)
new:SetPos(5, boneframe:GetHeight()-30)
new:SetSize(boneframe:GetWidth()-10, 25)
new:SetText("New")
function new:OnClick()
	local sel = boneframe.selected or TPose.root
	local name = "new_bone"
	local i = 1
	while TPose.bones[name..i] do i = i+1 end
	local bone = {name=name..i,rotation=0,length=10,at=0,parent=sel}
	sel.children = sel.children or {}
	sel.children[#sel.children+1] = bone
	TPose.bones[name..i] = bone
	TPose.animations.begin[1].data[bone.name] = {rotation=bone.rotation,length=bone.length,at=bone.at}
	boneframe:refreshTree()
end
