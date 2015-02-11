propertyframe = loveframes.Create("frame")
propertyframe:SetName("Properties")
propertyframe:SetState("edit")
propertyframe:SetPos(love.graphics.getWidth()-propertyframe:GetWidth(),0)
local columnlist = loveframes.Create("columnlist", propertyframe)
propertyframe.columnlist = columnlist
columnlist:SetPos(5, 30)
columnlist:SetSize(propertyframe:GetWidth()-10,propertyframe:GetHeight()-35)
columnlist:AddColumn("Name")
columnlist:AddColumn("Value")
columnlist:ResizeColumns()
function columnlist:OnRowClicked(clr, data, val)
	local i, v = data[1], data[2]
	--make floating edit box--
	local edit = loveframes.Create("textinput")
	edit:SetPos(love.mouse.getPosition())
	edit:SetText(v)
	edit:SetState("edit")
	function edit:OnEnter()
		self:Remove()
	end

	function edit:OnTextChanged()
		if i == "name" then
			local bn = boneframe.selected.name
			local nbn = edit:GetText()
			boneframe.selected[i] = nbn
			--also change the bone in the animation keyframe data
			for _, ani in pairs(TPose.animations) do
				for _, keyframe in pairs(ani) do
					keyframe.data[nbn] = keyframe.data[bn]
				end
			end
			data[2] = nbn
			TPose.bones[nbn] = TPose.bones[bn]
			boneframe:refreshTree()
		elseif i == "length" or i == "at" then
			local f,e = loadstring("return "..edit:GetText())
			boneframe.selected[i] = tonumber(select(2,pcall(f)) or 0) or 0
			--change bone stuff in current keyframe--
			local keyframe = TPose.animations[editor.animation][editor.keyframe].data
			keyframe[boneframe.selected.name] = keyframe[boneframe.selected.name] or {}
			keyframe[boneframe.selected.name][i] = boneframe.selected[i]
			data[2] = boneframe.selected[i]
		elseif i == "rotation" then
			local f,e = loadstring("return "..edit:GetText())
			boneframe.selected[i] = math.rad(tonumber(select(2,pcall(f)) or 0) or 0)
			local keyframe = TPose.animations[editor.animation][editor.keyframe].data
			keyframe[boneframe.selected.name] = keyframe[boneframe.selected.name] or {}
			keyframe[boneframe.selected.name][i] = boneframe.selected[i]
			print("set keyframe",i,editor.animation,editor.keyframe,boneframe.selected.name)
			data[2] = math.deg(boneframe.selected[i])
		end
	end

	function edit:OnFocusLost()
		self:Remove()
	end

	edit:SetFocus(true)
end
