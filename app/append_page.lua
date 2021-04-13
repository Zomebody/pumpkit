
local ui = require("framework.ui")
local vector = require("framework.datatypes.vector")
local color = require("framework.datatypes.color")
local Colors = require("app.color_palette")

local defaultFont = "LieraSansMedium.ttf"

local function colorString(str)
	local result = {}
	repeat
		local s1, e1 = string.find(str, "<[nbsfack]>")
		local s2, e2 = string.find(str, "</[nbsfack]>")
		if s1 ~= nil then
			if s1 ~= 1 then
				result[#result + 1] = Colors.MonokaiText:array()
				result[#result + 1] = str:sub(1, s1 - 1)
			end
			local char = str:sub(s1 + 1, s1 + 1)
			if char == "n" then
				result[#result + 1] = Colors.MonokaiNumber:array()
			elseif char == "b" then
				result[#result + 1] = Colors.MonokaiBoolean:array()
			elseif char == "s" then
				result[#result + 1] = Colors.MonokaiString:array()
			elseif char == "f" then
				result[#result + 1] = Colors.MonokaiFunction:array()
			elseif char == "a" then
				result[#result + 1] = Colors.MonokaiArgument:array()
			elseif char == "c" then
				result[#result + 1] = Colors.MonokaiComment:array()
			elseif char == "k" then
				result[#result + 1] = Colors.MonokaiKeyword:array()
			else
				result[#result + 1] = Colors.MonokaiText:array()
			end
			result[#result + 1] = str:sub(e1 + 1, s2 - 1)
			str = str:sub(e2 + 1)
		end
	until s1 == nil
	result[#result + 1] = Colors.MonokaiText:array()
	result[#result + 1] = str
	return result
end

local function create_doc(BodyRef, NavigationRef, data, DisplayVars, superClass)
	local content = data.Content
	local meta = data.Meta

	-- if you're populating the page with documentation from the superclass, add an extra separator and a button in the navigation
	if superClass ~= nil then
		-- separator
		local Separator = ui.newFrame(DisplayVars.BodyWidth, 30, Colors.BackgroundSemiDark)
		Separator:setPadding(DisplayVars.PagePaddingLeft, 6)
		Separator:setText(defaultFont, {Colors.TextComment:array(), "From <" .. superClass .. ">"}, DisplayVars.HeaderFontSize, true)
		Separator:resize(Separator.Size.x, Separator.Size.y + 30)
		Separator.TextBlock:alignX("left")
		Separator.TextBlock:alignY("bottom")
		if #BodyRef.Children > 0 then
			Separator:putNextTo(BodyRef.Children[#BodyRef.Children], "below")
			Separator:alignX("left")
		end
		BodyRef:addChild(Separator)

		-- navigation button
		local Line = ui.newFrame(DisplayVars.NavigationWidth, 4, Colors.BackgroundLight)
		if #NavigationRef.Children > 0 then
			Line:putNextTo(NavigationRef.Children[#NavigationRef.Children], "below")
		end
		NavigationRef:addChild(Line)
		local Button = ui.newFrame(DisplayVars.NavigationWidth, 30, Colors.Transparent)
		Button:setPadding(8, 4)
		Button:setText(defaultFont, {Colors.TextComment:array(), "<" .. superClass .. ">"}, DisplayVars.TextSize, true)
		Button.OnFullPress = function(x, y, button)
			if button == 1 then
				BodyRef.Parent:positionContent(0, -Separator.Position.Offset.y)
			end
		end
		Button:resize(Button.Size.x, Button.Size.y + 4)
		Button.TextBlock:alignY("bottom")
		Button:putNextTo(NavigationRef.Children[#NavigationRef.Children], "below")
		Button.ColorHover = Colors.ButtonHover
		Button.ColorHold = Colors.ButtonHold
		NavigationRef:addChild(Button)
	end

	-- loop through all the items in the object docs
	for i = 1, #content do
		local Item = content[i]

		-- IntroHeader is skipped if the object is inherited, as IntroHeaders are meant for only the documentation of the object itself, not for inherited items
		if not (Item.Type == "IntroHeader" and superClass ~= nil) then
			-- documentation in the body
			local JumpToObject = nil
			if Item.Type == "Header" or Item.Type == "IntroHeader" then
				local Header = ui.newFrame(DisplayVars.BodyWidth, 30, Colors.BackgroundLight)
				Header:setPadding(DisplayVars.PagePaddingLeft, 6)
				Header:setText(defaultFont, Item.Name, DisplayVars.HeaderFontSize, true)
				Header.TextBlock:alignX("left")
				if #BodyRef.Children > 0 then
					Header:putNextTo(BodyRef.Children[#BodyRef.Children], "below")
				end
				Header:alignX("left")
				BodyRef:addChild(Header)
				JumpToObject = Header
				if Item.Note ~= nil then
					local Note = ui.newFrame(Header.Size.x - Header.PaddingX * 2, Header.Size.y - Header.PaddingY * 2, Colors.Transparent)
					Note:setText(defaultFont, {Colors.TextComment:array(), Item.Note}, DisplayVars.TextSize)
					Note.TextBlock:alignX("right")
					Note.TextBlock:alignY("bottom")
					Header:addChild(Note)
				end
			else
				-- property / method title
				local titleText = {{1, 1, 1}, Item.Name}
				if Item.Type == "Property" then
					if Item.ValueType:lower() == "number" then
						table.insert(titleText, 1, Colors.MonokaiNumber:array())
					elseif Item.ValueType:lower() == "string" then
						table.insert(titleText, 1, Colors.MonokaiString:array())
					elseif Item.ValueType:lower() == "boolean" then
						table.insert(titleText, 1, Colors.MonokaiBoolean:array())
					elseif Item.ValueType:lower() == "object" then
						table.insert(titleText, 1, Colors.MonokaiKeyword:array())
					else
						table.insert(titleText, 1, Colors.MonokaiFunction:array())
					end
					table.insert(titleText, 2, Item.ValueType .. " ")
					if Item.ReadOnly then
						table.insert(titleText, Colors.TextAlternative:array())
						table.insert(titleText, " [READ-ONLY]")
					end
				elseif Item.Type == "Callback" then
					titleText[1] = Colors.MonokaiText:array()
					table.insert(titleText, 1, "callback ")
					table.insert(titleText, 1, Colors.MonokaiKeyword:array())
					table.insert(titleText, Colors.MonokaiText:array())
					table.insert(titleText, "(")
					for k = 1, #Item.Arguments do
						table.insert(titleText, Colors.MonokaiArgument:array())
						table.insert(titleText, Item.Arguments[k])
						if k ~= #Item.Arguments then
							table.insert(titleText, Colors.MonokaiText:array())
							table.insert(titleText, ", ")
						end
					end
					table.insert(titleText, Colors.MonokaiText:array())
					table.insert(titleText, ")")
				elseif Item.Type == "Method" or Item.Type == "Constructor" then
					local dot = Item.Type == "Method" and ":" or "."
					titleText[1] = Colors.MonokaiFunction:array()
					table.insert(titleText, 1, data.Meta.Name .. dot)
					table.insert(titleText, 1, Colors.MonokaiText:array())
					table.insert(titleText, Colors.MonokaiText:array())
					table.insert(titleText, "(")
					for k = 1, #Item.Arguments do
						table.insert(titleText, Colors.MonokaiArgument:array())
						table.insert(titleText, Item.Arguments[k])
						if k ~= #Item.Arguments then
							table.insert(titleText, Colors.MonokaiText:array())
							table.insert(titleText, ", ")
						end
					end
					table.insert(titleText, Colors.MonokaiText:array())
					table.insert(titleText, ")")
				end
				local Title = ui.newFrame(DisplayVars.BodyWidth, 30, Colors.Transparent)
				Title:setPadding(DisplayVars.PagePaddingLeft, 6)
				Title:setText(defaultFont, titleText, DisplayVars.TitleFontSize, true)
				Title.TextBlock:alignX("left")
				Title.TextBlock:alignY("bottom")
				if #BodyRef.Children > 0 then
					Title:putNextTo(BodyRef.Children[#BodyRef.Children], "below", 2)
					Title:alignX("left")
				end
				BodyRef:addChild(Title)
				JumpToObject = Title
			end

			local Desc = nil
			if Item.Description and Item.Description:len() > 0 then
				-- description
				Desc = ui.newFrame(DisplayVars.BodyWidth, 16, Colors.Transparent)
				Desc:setPadding(DisplayVars.PagePaddingLeft, 0)
				Desc:setText(defaultFont, {Colors.TextPrimary:array(), Item.Description}, DisplayVars.TextSize, true)
				Desc.TextBlock:alignX("left")
				if #BodyRef.Children > 0 then
					Desc:putNextTo(BodyRef.Children[#BodyRef.Children], "below", (Item.Type == "Header" and 12 or 4))
					Desc:alignX("left")
				end
				BodyRef:addChild(Desc)
			end

			-- code block
			if Item.CodeMarkup ~= nil then
				local CodeTitle = ui.newFrame(DisplayVars.BodyWidth - DisplayVars.PagePaddingLeft * 2, 28, Colors.Border)
				CodeTitle:setPadding(10, 0)
				CodeTitle:putNextTo(BodyRef.Children[#BodyRef.Children], "below", 16)
				CodeTitle:alignX("center")
				CodeTitle:setText(defaultFont, {Colors.TextTableHeader:array(), "Code example"}, DisplayVars.TextSize)
				CodeTitle.TextBlock:alignY("bottom")
				BodyRef:addChild(CodeTitle)
				local CodeFrame = ui.newFrame(CodeTitle.Size.x, 100, Colors.BackgroundDark)
				CodeFrame:setPadding(14, 14)
				CodeFrame:setText("FiraCode.ttf", colorString(Item.CodeMarkup), DisplayVars.TextSize, true)
				CodeFrame.BorderColor = Colors.Border
				CodeFrame:setBorder(4)
				CodeFrame:putNextTo(BodyRef.Children[#BodyRef.Children], "below")
				CodeFrame:alignX("center")
				BodyRef:addChild(CodeFrame)
				local CopyIcon = love.graphics.newImage("test_images/copy_icon.png")
				local CopyButton = ui.newImageFrame(CopyIcon, CopyIcon:getWidth(), CopyIcon:getHeight(), Colors.TextTableHeader)
				CopyButton.ColorHover = color(CopyButton.Color):darken(0.25)
				CopyButton.ColorHold = color(CopyButton.Color):darken(0.6)
				CopyButton:alignX("right")
				CopyButton:alignY("center")
				CopyButton.OnFullPress = function()
					love.system.setClipboardText(CodeFrame.TextBlock.RawText)
				end
				CodeTitle:addChild(CopyButton)
			end

			if Item.Demo then
				local Obj = Item.Demo()
				Obj:putNextTo(BodyRef.Children[#BodyRef.Children], "below", 12)
				Obj:alignX("left")
				Obj:shift(DisplayVars.PagePaddingLeft, 0)
				BodyRef:addChild(Obj)
			end

			-- divider
			local dividerThickness = DisplayVars.DividerThickness
			if content[i + 1] ~= nil and content[i + 1].Type == "Header" then
				dividerThickness = dividerThickness * 6
			end
			local Divider = ui.newFrame(DisplayVars.BodyWidth, dividerThickness, Colors.BackgroundSemiDark)
			Divider:putNextTo(BodyRef.Children[#BodyRef.Children], "below", Desc == nil and 0 or 12)
			Divider:alignX("left")
			BodyRef:addChild(Divider)

			-- button in the navigation
			local Button = ui.newFrame(DisplayVars.NavigationWidth, 30, Colors.Transparent)
			local TextColor = (Item.Type == "Header") and Colors.TextWhite or Colors.TextPrimary
			if Item.Type == "Header" or Item.Type == "IntroHeader" then
				Button:setPadding(8, 4)
			else
				Button:setPadding(22, 4)
			end
			Button:setText(defaultFont, {TextColor:array(), Item.Name}, DisplayVars.TextSize, true)
			Button.OnFullPress = function(x, y, button)
				if button == 1 and not ui.DragActive then
					BodyRef.Parent:positionContent(0, -JumpToObject.Position.Offset.y)
				end
			end
			if Item.Type == "Header" or Item.Type == "IntroHeader" then
				Button:resize(Button.Size.x, Button.Size.y + 10)
				Button.TextBlock:alignY("bottom")
			end
			if #NavigationRef.Children > 0 then
				Button:putNextTo(NavigationRef.Children[#NavigationRef.Children], "below")
			end
			Button.ColorHover = Colors.ButtonHover
			Button.ColorHold = Colors.ButtonHold
			NavigationRef:addChild(Button)
		end
	end
end

return create_doc