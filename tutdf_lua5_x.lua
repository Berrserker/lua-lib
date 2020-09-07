module(... ,package.seeall) --������� ���������� ������, ���� ������ ���������� �� ��������-���������� ��� ������������.
require ("XML")
require ('xsd_text')


function dataFormat(data)
	data = tostring(data)
	if #data==8 then
		local format=string.sub(data,7,8).."."..string.sub(data,5,6).."."..string.sub(data,1,4)
		return format
	else
		return ""
	end
end

local head = {}

local logfile = {}

local action = {}

local write_action = {}

local messageID = {} --- this var need to set FL|UL person type, and write the ID_tag in virtual XML

local collisei = {}--- this var need to set FL|UL person type, and write the ID_tag in virtual XML

local PersonEnding= {
			["IP"] = 'true',
			["TR"] = 'true',
			["LE"] = 'true',
			["BK"] = 'true',
			["BC"] = 'true',
}

function PersonEndings(Module)
	if PersonEnding[Module] then return true end
	return false
	--[=[--local ok,res=pcall(f1,p1,p2)
	local ok,res=pcall(do
		local act= PersonEnding[Module]
		local act2= PersonEnding[Module]..'cocos'
		end)
	--MsgBox(render{'ok',ok,'res',res})
	if ok then return true
	else return false
	end
	--MsgBox(render{ok,res,Module})
--]=]
end

--local function setGlobal()
local function setGlobal(logName,TUTDF)


	--typePrson=""

	logfile = [[c:\tmp\]]..logName..[[__]]..IO.Path.GetFileName(TUTDF)..[[.log]]

	action = {
		["ID"] = Read_ID,
		["NA"] = Read_NA,
		["BU"] = Read_BU,
		["AD"] = Read_AD,
		["PN"] = Read_PN,
		["CL"] = Read_CL,
		["BG"] = Read_BG,
		["GR"] = Read_GR,
		["TR"] = Read_TR,
		["LE"] = Read_LE,
		["BK"] = Read_BK,
		["BC"] = Read_BC,
		["IP"] = Read_IP,
		["PA"] = Read_PA,
		["TUTDF"] = Read_Header,
	}

	write_action= {
		["PA"] = Write_PA,
		["ID"] = Write_ID,
		["NA"] = Write_NA,
		["BU"] = Write_BU,
		["AD"] = Write_AD,
		["PN"] = Write_PN,
		["CL"] = Write_CL,
		["BG"] = Write_BG,
		["GR"] = Write_Nothing,
		["TR"] = Write_TR,
		["LE"] = Write_LE,
		["BK"] = Write_BK,
		["BC"] = Write_BC,
		["IP"] = Write_IP,
	}
end

function Write_PA(node, value)
	if node.CreditInfo'$n'>0 then
		if node.CreditInfo.Payments'$n'>0 then
		local mode = node.CreditInfo.Payments:AddNode("Payment")
			mode:AddNode("DatePayment"):SetData(dataFormat(value[5]))
			mode:AddNode("SumPayment"):SetData(value[2])
			mode:AddNode("SumPayment30"):SetData(value[3])
			mode:AddNode("Currency"):SetData(value[4])
			mode:AddNode("PaymentVolume"):SetData(value[6])
			mode:AddNode("PaymentAmountExcept24m")
			mode["PaymentAmountExcept24m"]:SetData(value[7])
		end
	end
	Log("write PA")
	return true, false, node
end

function Write_ID(node, val, flag)
	--MsgBox(render(node))
	local anode = node
	if flag then
		Log('Write_ID flag true')
		--MsgBox(render(messageID))
		--Log(render(val))
        for z,value in pairs(val) do
            --MsgBox(xrender(val, z, value))
			if node.LegalPerson'$n'>0 then
				--Log('UL')
				--Log(value[2])
				local TypeID=
				{
					["34"]= function (node, value)
						node.LegalPerson.OGRN:SetData(value[4])
						return node
						end,
					["35"]= function (node, value)
						local ad  = mode.LegalPerson:AddNode("AddDocument")
						ad:AddNode("Type")
						ad:AddNode("SeriesAndNumber")
						ad:AddNode("IssueDate")
						ad:AddNode("IssueInfo")
						ad.IssueDate:SetData(dataFormat(value[5]))
						ad.IssueInfo:SetData(value[6])
						ad.SeriesAndNumber:SetData(value[3]..value[4])
						ad.Type:SetData('7')
						return mode
						end,
					["81"]= function (node, value)
						node.LegalPerson.INN:SetData(value[4])
						return node
						end,
					["82"]= function (node, value)
						node.LegalPerson.INN:SetData(value[4])
						return node
						end,
					["98"]= function (node, value)
						Log("98")
						Log("value")
						return node
						end,
					["99"]= function (node, value)
						Log("99")
						Log("value")
						return node
						end,
				}
				anode = TypeID[value[2]](node, value)
				--MsgBox(render(aa:ToString()))
			else
				if node.NaturalPerson'$n'>0 then
					--MsgBox(node.NaturalPerson'$n')
					--Log('FL')
					local TypeID=
					{
						["01"]= function (mode, value)
							--MsgBox(render(mode:))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('14')
							return mode
							end,
						["02"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('15')
							return mode
							end,
						["03"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('2')
							return mode
							end,
						["04"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('3')
							return mode
							end,
						["06"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('12')
							return mode
							end,
						["07"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('4')
							return mode
							end,
						["09"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('12')
							return mode
							end,
						["10"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('6')
							return mode
							end,
						["12"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('8')
							return mode
							end,
						["13"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('10')
							return mode
							end,
						["14"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('11')
							return mode
							end,
						["15"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('7')
							return mode
							end,
						["21"]= function (mode, value)
							local ad = mode.NaturalPerson:AddNode("PassportRF")
							ad:AddNode("SeriesAndNumber")
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad:AddNode("IssueDate")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad:AddNode("IssueInfo")
							ad.IssueInfo:SetData(value[6])
							return mode
							end,
						["22"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('13')
							return mode
							end,
						["26"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('5')
							return mode
							end,
						["27"]= function (mode, value)
							--MsgBox(render(value))
							--MsgBox(render(ad.NaturalPerson:ToString()))
							local ad  = mode.NaturalPerson:AddNode("AddDocument")
							ad:AddNode("Type")
							ad:AddNode("SeriesAndNumber")
							ad:AddNode("IssueDate")
							ad:AddNode("IssueInfo")
							ad.IssueDate:SetData(dataFormat(value[5]))
							ad.IssueInfo:SetData(value[6])
							ad.SeriesAndNumber:SetData(value[3]..value[4])
							ad.Type:SetData('16')
							return mode
							end,
						["31"]= function (mode, value)
							mode.NaturalPerson.INN:SetData(value[4])
							return mode
							end,
						["32"]= function (mode, value)
							mode.NaturalPerson.Insurance:SetData(value[4])
							return mode
							end,
						["33"]= function (mode, value)
							mode.NaturalPerson.OGRNIP:SetData(value[4])
							return mode
							end,
						["91"]= function (mode, value)
							Log("98")
							Log("value")
							return node
							end,
						["97"]= function (mode, value)
							Log("98")
							Log("value")
							return node
							end,
						["98"]= function (node, value)
							Log("98")
							Log("value")
							return node
							end,
						["99"]= function (node, value)
							Log("99")
							Log("value")
							return node
							end,
						["81"]= function (mode, value)
							mode.NaturalPerson.INN:SetData(value[4])
							return mode
							end,
					}
					--Log(xrender(value[2], value))
                    anode = TypeID[tostring(value[2])](node, value)
                    --Log(anode:ToString())
				end
			end
		end
		messageID = {}
		collectgarbage()
		--Log(xrender(messageID))
	else
		Log('Write_ID flag false')
		--MsgBox(render(val))
		table.insert(messageID, val)
		--MsgBox(render(messageID))n
	end
	--MsgBox(render(anode))
	--MsgBox(render(node.NaturalPerson))
	return true, false, anode
end

function Write_NA(node, value)
	node:AddNode("NaturalPerson")
	node.NaturalPerson:AddNode("Surname")
	node.NaturalPerson.Surname:SetData(value[2])
	node.NaturalPerson:AddNode("FirstName")
	node.NaturalPerson.FirstName:SetData(value[4])
	node.NaturalPerson:AddNode("PatronymicName")
	node.NaturalPerson.PatronymicName:SetData(value[3])
	node.NaturalPerson:AddNode("DateOfBirth")
	node.NaturalPerson.DateOfBirth:SetData(dataFormat(value[6]))
	node.NaturalPerson:AddNode("PlaceOfBirth")
	node.NaturalPerson.PlaceOfBirth:SetData(value[7])
	node.NaturalPerson:AddNode("OldSurname")
	node.NaturalPerson.OldSurname:SetData(value[12])
	node.NaturalPerson:AddNode("OldFirstName")
	node.NaturalPerson.OldFirstName:SetData(value[13])
	node.NaturalPerson:AddNode("DateRegisterIP")
	node.NaturalPerson:AddNode("OGRNIP")
	node.NaturalPerson:AddNode("Insurance")
	node.NaturalPerson:AddNode("INN")
	Log("write NA")
    local send = node
    --Log(xrender(messageID))
	_,_,node =	Write_ID(send, messageID, true)
	return true, false, node
end

function Write_BU(node, value)
	node:AddNode("LegalPerson")
	node.LegalPerson:AddNode("FullName")
	node.LegalPerson.FullName:SetData(value[2])
	node.LegalPerson:AddNode("ShortName")
	node.LegalPerson.ShortName:SetData(value[17])
	node.LegalPerson:AddNode("FirmName")
	node.LegalPerson.FirmName:SetData(value[23])
	node.LegalPerson:AddNode("EngName")
	node.LegalPerson.EngName:SetData(value[25])
	node.LegalPerson:AddNode("OGRN")
	node.LegalPerson:AddNode("RegistrtionNumber")
	node.LegalPerson:AddNode("INN")
	node.LegalPerson:AddNode("ReorganizationFullName")
	node.LegalPerson.ReorganizationFullName:SetData(value[18])
	node.LegalPerson:AddNode("ReorganizationShortName")
	node.LegalPerson.ReorganizationShortName:SetData(value[22])

	Log("write BU")
	--Log(xrender(_G.messageID))
	local send = node
	_,_,node=	Write_ID(node, messageID, true)
	return true, false, node
end

function Write_AD(node, value)
	--Log(node:ToString())
	if node.LegalPerson'$n'>0 then
		if node.LegalPerson.RegistrationAddress'$n'<1 then
			node.LegalPerson:AddNode("RegistrationAddress")
		end
		node.LegalPerson:AddNode("RegistrationAddressPhone")
		if node.LegalPerson.FactAddress'$n'<1 then
			node.LegalPerson:AddNode("FactAddress")
		end
		if value[2] == '4' then
			node.LegalPerson.FactAddress:AddNode("PostalCode")
			node.LegalPerson.FactAddress.PostalCode:SetData(value[3])
			node.LegalPerson.FactAddress:AddNode("Country")
			node.LegalPerson.FactAddress.Country:SetData(value[4])
			node.LegalPerson.FactAddress:AddNode("Region")
			node.LegalPerson.FactAddress.Region:SetData(value[5])
			node.LegalPerson.FactAddress:AddNode("Location")
			node.LegalPerson.FactAddress.Location:SetData(value[8])
			node.LegalPerson.FactAddress:AddNode("District")
			node.LegalPerson.FactAddress.District:SetData(value[7])
			node.LegalPerson.FactAddress:AddNode("Street")
			node.LegalPerson.FactAddress.Street:SetData(value[10])
			node.LegalPerson.FactAddress:AddNode("HouseNumber")
			node.LegalPerson.FactAddress.HouseNumber:SetData(value[11])
			node.LegalPerson.FactAddress:AddNode("Block")
			node.LegalPerson.FactAddress.Block:SetData(value[12])
			node.LegalPerson.FactAddress:AddNode("Building")
			node.LegalPerson.FactAddress.Building:SetData(value[13])
			node.LegalPerson.FactAddress:AddNode("Apartment")
			node.LegalPerson.FactAddress.Apartment:SetData(value[14])
		else
			if value[2] == '3' then
				node.LegalPerson.RegistrationAddress:AddNode("PostalCode")
				node.LegalPerson.RegistrationAddress.PostalCode:SetData(value[3])
				node.LegalPerson.RegistrationAddress:AddNode("Country")
				node.LegalPerson.RegistrationAddress.Country:SetData(value[4])
				node.LegalPerson.RegistrationAddress:AddNode("Region")
				node.LegalPerson.RegistrationAddress.Region:SetData(value[5])
				node.LegalPerson.RegistrationAddress:AddNode("Location")
				node.LegalPerson.RegistrationAddress.Location:SetData(value[8])
				node.LegalPerson.RegistrationAddress:AddNode("District")
				node.LegalPerson.RegistrationAddress.District:SetData(value[7])
				node.LegalPerson.RegistrationAddress:AddNode("Street")
				node.LegalPerson.RegistrationAddress.Street:SetData(value[10])
				node.LegalPerson.RegistrationAddress:AddNode("HouseNumber")
				node.LegalPerson.RegistrationAddress.HouseNumber:SetData(value[11])
				node.LegalPerson.RegistrationAddress:AddNode("Block")
				node.LegalPerson.RegistrationAddress.Block:SetData(value[12])
				node.LegalPerson.RegistrationAddress:AddNode("Building")
				node.LegalPerson.RegistrationAddress.Building:SetData(value[13])
				node.LegalPerson.RegistrationAddress:AddNode("Apartment")
				node.LegalPerson.RegistrationAddress.Apartment:SetData(value[14])
			else
				Log("error AD in value 10")
				return false, false, node
			end
		end
	else
		if node.NaturalPerson'$n'>0 then
			--Log("FL ADRESS START")
			if node.NaturalPerson.RegistrationAddress'$n'<1 then
				node.NaturalPerson:AddNode("RegistrationAddress")
				--Log('RegistrationAddress')
			end
			if node.NaturalPerson.LivingAddress'$n'<1 then
				node.NaturalPerson:AddNode("LivingAddress")
				--Log('LivingAddress')
			end
			if value[2] == '2' then
				node.NaturalPerson.LivingAddress:AddNode("PostalCode")
				node.NaturalPerson.LivingAddress.PostalCode:SetData(value[3])
				node.NaturalPerson.LivingAddress:AddNode("Country")
				node.NaturalPerson.LivingAddress.Country:SetData(value[4])
				node.NaturalPerson.LivingAddress:AddNode("Region")
				node.NaturalPerson.LivingAddress.Region:SetData(value[5])
				node.NaturalPerson.LivingAddress:AddNode("Location")
				node.NaturalPerson.LivingAddress.Location:SetData(value[8])
				node.NaturalPerson.LivingAddress:AddNode("District")
				node.NaturalPerson.LivingAddress.District:SetData(value[7])
				node.NaturalPerson.LivingAddress:AddNode("Street")
				node.NaturalPerson.LivingAddress.Street:SetData(value[10])
				node.NaturalPerson.LivingAddress:AddNode("HouseNumber")
				node.NaturalPerson.LivingAddress.HouseNumber:SetData(value[11])
				node.NaturalPerson.LivingAddress:AddNode("Block")
				node.NaturalPerson.LivingAddress.Block:SetData(value[12])
				node.NaturalPerson.LivingAddress:AddNode("Building")
				node.NaturalPerson.LivingAddress.Building:SetData(value[13])
				node.NaturalPerson.LivingAddress:AddNode("Apartment")
				node.NaturalPerson.LivingAddress.Apartment:SetData(value[14])
			else
				--MsgBox(value[2])
				if (value[2] == '1') then
					node.NaturalPerson.RegistrationAddress:AddNode("PostalCode")
					node.NaturalPerson.RegistrationAddress.PostalCode:SetData(value[3])
					node.NaturalPerson.RegistrationAddress:AddNode("Country")
					node.NaturalPerson.RegistrationAddress.Country:SetData(value[4])
					node.NaturalPerson.RegistrationAddress:AddNode("Region")
					node.NaturalPerson.RegistrationAddress.Region:SetData(value[5])
					node.NaturalPerson.RegistrationAddress:AddNode("Location")
					node.NaturalPerson.RegistrationAddress.Location:SetData(value[8])
					node.NaturalPerson.RegistrationAddress:AddNode("District")
					node.NaturalPerson.RegistrationAddress.District:SetData(value[7])
					node.NaturalPerson.RegistrationAddress:AddNode("Street")
					node.NaturalPerson.RegistrationAddress.Street:SetData(value[10])
					node.NaturalPerson.RegistrationAddress:AddNode("HouseNumber")
					node.NaturalPerson.RegistrationAddress.HouseNumber:SetData(value[11])
					node.NaturalPerson.RegistrationAddress:AddNode("Block")
					node.NaturalPerson.RegistrationAddress.Block:SetData(value[12])
					node.NaturalPerson.RegistrationAddress:AddNode("Building")
					node.NaturalPerson.RegistrationAddress.Building:SetData(value[13])
					node.NaturalPerson.RegistrationAddress:AddNode("Apartment")
					node.NaturalPerson.RegistrationAddress.Apartment:SetData(value[14])
				else
				Log("error AD in value 2")
					return false, false, node
				end
			end
		end
	end
	Log("write AD")
	return true, false, node
end

function Write_PN(node, value)

	if node.LegalPerson'$n'>0 then
		node.LegalPerson.RegistrationAddressPhone:SetData(value[2])
	--[[else
		if node.NaturalPerson'$n'>0 then
			node.NaturalPerson:AddNode("RegistrationAddressPhone")
			node.NaturalPerson.RegistrationAddressPhone:SetData(value[2])
		else
			Log("error pn in value")
			return false, "error PN in value", node
		end]]--
	end

	Log("write PN")
	return true, false, node

end

function Write_CL(node, value)
	if node.CreditInfo'$n'>0 then
		if node.CreditInfo.Ensures'$n'>0 then
			local mode = node.CreditInfo.Ensures:AddNode("Ensure")
			mode:AddNode("IDEnsure")
			mode.IDEnsure:SetData(value[2])
			mode:AddNode("CollateralValue")
			mode.CollateralValue:SetData(value[4])
			mode:AddNode("Currency")
			mode.Currency:SetData(value[7])
			mode:AddNode("CollateralDate")
			mode.CollateralDate:SetData(dataFormat(value[5]))
			mode:AddNode("EnsureDateEnd")
			mode.EnsureDateEnd:SetData(dataFormat(value[6]))
		end
	end
	Log("write CL")
	return true, false, node

end

function Write_Nothing(node, value)
	Log("write Nothing")
	return true, false, node

end

function Write_GR(node, value)
	if node.CreditInfo'$n'>0 then
		if node.CreditInfo.GuaranteeInfos'$n'<1 then
			node.CreditInfo:AddNode("GuaranteeInfos")
		end
		local guarante = node.CreditInfo.GuaranteeInfos:AddNode("GuaranteeInfo")
		guarante:AddNode("Volume")
		guarante.Volume:SetData(value[3])
		guarante:AddNode("Summ")
		guarante.Summ:SetData(value[4])

		--guarante:AddNode("GuaranteeNumber")
		--guarante.GuaranteeNumber:SetData(value[2])
		guarante:AddNode("DateClosed")
		guarante.DateClosed:SetData(dataFormat(value[5]))

		--guarante:AddNode("GuaranteeCurrency")
		--guarante.GuaranteeCurrency:SetData(value[6])

	end
	Log("write GR")
	return true, false, node

end

function Write_BG(node, value)
	if node.CreditInfo'$n'>0 then
		if node.CreditInfo.BankGuarantes'$n'<1 then
			node.CreditInfo:AddNode("BankGuarantes")
		end
		local bank = node.CreditInfo.BankGuarantes:AddNode("BankGuaranty")
		bank:AddNode("Volume")
		bank.Volume:SetData(value[3])
		bank:AddNode("Summ")
		bank.Summ:SetData(value[4])
		bank:AddNode("DateClosed")
		bank.DateClosed:SetData(dataFormat(value[5]))
	end
	Log("write BG")
	return true, false, node

end

function Write_LE(node, value)
	if node.LegalPerson'$n'>0 then
		node:AddNode("Claim")
		node.Claim:AddNode("ClaimNumber")
		node.Claim.ClaimNumber:SetData(value[2])
		node.Claim:AddNode("CourtName")
		node.Claim.CourtName:SetData(value[3])
		node.Claim:AddNode("DateConsideration")
		node.Claim.DateConsideration:SetData(dataFormat(value[5]))
		node.Claim:AddNode("Plaintiff")
		node.Claim.Plaintiff:SetData(dataFormat(value[7]))
		node.Claim:AddNode("Resolution")
		node.Claim.Resolution:SetData(value[8])
	else
			Log("error LE in value")
			return false, "error LE in value", node
	end
	Log("write LE")
	return true, false, node

end

function Write_BK(node, value)
	if	node.LegalPerson'$n'>0 then
		node:AddNode("BankruptcyLP")
		node.BankruptcyLP:AddNode("IDBankruptcy")
		node.BankruptcyLP.IDBankruptcy:SetData(value[3])
		node.BankruptcyLP:AddNode("CourtName")
		node.BankruptcyLP.CourtName:SetData(value[2])
		node.BankruptcyLP:AddNode("ClaimNumber")
		node.BankruptcyLP.ClaimNumber:SetData(value[3])
		node.BankruptcyLP:AddNode("DateConsideration")
		node.BankruptcyLP.DateConsideration:SetData(dataFormat(value[4]))
		node.BankruptcyLP:AddNode("Status")
		node.BankruptcyLP.Status:SetData(value[7])
		node.BankruptcyLP:AddNode("Resolution")
		node.BankruptcyLP.Resolution:SetData(value[8])
	else
			Log("error BK in value")
			return false, "error BK in value", node
	end
	Log("write BK")
	return true, false, node

end

function Write_BC(node, value)

	if	node.NaturalPerson'$n'>0 then
		node:AddNode("BankruptcyNP")
		node.BankruptcyNP:AddNode("IDBankruptcy")
		node.BankruptcyNP.IDBankruptcy:SetData(value[3])
		node.BankruptcyNP:AddNode("TypeOfBankruptcyProcedure")
		node.BankruptcyNP.TypeOfBankruptcyProcedure:SetData(value[5])
		node.BankruptcyNP:AddNode("DateOfInclusion")
		node.BankruptcyNP.DateOfInclusion:SetData(dataFormat(value[6]))
		if value[8] == '3' then
			node.BankruptcyNP:AddNode("OtherAdditionalInformation")
			node.BankruptcyNP.OtherAdditionalInformation:SetData(value[9])
		else
			node.BankruptcyNP:AddNode("AdditionalInformation")
			node.BankruptcyNP.AdditionalInformation:SetData(value[8])
		end
		node.BankruptcyNP:AddNode("FinancialManagerPowersStartDate")
		node.BankruptcyNP.FinancialManagerPowersStartDate:SetData(dataFormat(value[11]))
		node.BankruptcyNP:AddNode("FinancialManagerPowersEndDate")
		node.BankruptcyNP.FinancialManagerPowersEndDate:SetData(dataFormat(value[12]))
			Log("error BC in value")
			return false, "error BC in value", node
	end

	Log("write BC")
	return true, false, node

end

function Write_IP(node, value)
	node.PartnerID:SetData(value[2])
	node:AddNode("ApplicationInfo")
	node.ApplicationInfo:AddNode("ApplicationNumber")
	node.ApplicationInfo.ApplicationNumber:SetData(value[3])
	node.ApplicationInfo:AddNode("ApplicationDate")
	node.ApplicationInfo.ApplicationDate:SetData(dataFormat(value[4]))
	node.ApplicationInfo:AddNode("ApplicationType")
	node.ApplicationInfo.ApplicationType:SetData(value[7])
	node.ApplicationInfo:AddNode("ApplicationChannel")
	node.ApplicationInfo.ApplicationChannel:SetData(value[8])
	if value[9] == 'Y' then
		node.ApplicationInfo:AddNode("ResolutionDate")
		node.ApplicationInfo.ResolutionDate:SetData(dataFormat(value[10]))
		node.ApplicationInfo:AddNode("ResolutionYes")
		node.ApplicationInfo.ResolutionYes:AddNode("ApplicationDateClose")
		node.ApplicationInfo.ResolutionYes.ApplicationDateClose:SetData(dataFormat(value[10]))
		node.ApplicationInfo.ResolutionYes:AddNode("CreditNumber")
		node.ApplicationInfo.ResolutionYes.CreditNumber:SetData(value[15])
		node.ApplicationInfo.ResolutionYes:AddNode("ApplicationType")
		if value[16]~="" then
			node.ApplicationInfo.ResolutionYes.ApplicationType:SetData(value[16])
		else
			node.ApplicationInfo.ResolutionYes.ApplicationType:SetData(value[7])
		end
	else
		if value[9] == 'F' then
			node.ApplicationInfo:AddNode("ResolutionDate")
			node.ApplicationInfo.ResolutionDate:SetData(dataFormat(value[13]))
			node.ApplicationInfo:AddNode("ResolutionNo")
			node.ApplicationInfo.ResolutionNo:AddNode("RejectType")
			node.ApplicationInfo.ResolutionNo.RejectType:SetData(value[14])
			node.ApplicationInfo.ResolutionNo:AddNode("RejectText")
			local rejecttext = {
			["1"] = '��������� �������� ����������',
			["2"] = '��������� ������� �������� (����������)',
			["3"] = '���������� �������� �������� �������� (����������)',
			["4"] = '�������������� ����� ������� � �����������, ��������� ���������',
			["5"] = '������',
			}
			node.ApplicationInfo.ResolutionNo.RejectText:SetData(rejecttext[value[14]])
		else
			Log('Err in IP')
		end
	end
	Log("write IP")
	return true, false, node
end

function Write_TR(node, value)
	node.PartnerID:SetData(value[2])
	node.CreatePackDate:SetData(dataFormat(head[6]))
	node.RelevanceDate:SetData(dataFormat(value[10]))

	if value[5] == '1' or value[5] == '9' then
		--typePrson="1"

		node.TypeBorrower:SetData("1")

		local crInfo=node:AddNode("CreditInfo")
			crInfo:AddNode("ID"):SetData(value[50])
			crInfo:AddNode("CreditType"):SetData(value[4])
			crInfo:AddNode("CreditNumber"):SetData(value[3])
			crInfo:AddNode("CreditDateOpened"):SetData(dataFormat(value[6]))
			crInfo:AddNode("CreditSum"):SetData(value[11])
			crInfo:AddNode("CreditDateFinal"):SetData(dataFormat(value[20]))
			crInfo:AddNode("CreditInterestDateFinal"):SetData(dataFormat(value[21]))
			crInfo:AddNode("CreditCurrency"):SetData(value[17])
			crInfo:AddNode("CreditSummFull"):SetData(value[37])
			if value[49]~="" then
				crInfo:AddNode("DateStartGracePeriod"):SetData(dataFormat(value[10]))
				crInfo:AddNode("DateEndGracePeriod"):SetData(dataFormat(value[49]))
			end

			crInfo:AddNode("SumNextPayment"):SetData(value[14]) -- ����������� ��� ����
			--���� ���������� �������
			crInfo:AddNode("DateLastPayment"):SetData(dataFormat(value[7]))
			--������� ������������� �� ���� ���������� �������
			crInfo:AddNode("CurrentCreditSum"):SetData(value[43])
			crInfo:AddNode("CurrentCreditSumPerc"):SetData(value[44])
			crInfo:AddNode("OtherAmount"):SetData(value[45])
			--������� ������������� �� ���� ����������� ������
			crInfo:AddNode("CurrentCreditSumPast"):SetData(value[25])
			--������������ ������������� �� ���� �������
			crInfo:AddNode("DelaySum"):SetData(value[46])
			crInfo:AddNode("DelaySumPerc"):SetData(value[47])
			crInfo:AddNode("OtherDelaySum"):SetData(value[48])
			--������� ������������ ������������� �� ���� �������� ����������
			crInfo:AddNode("DelaySumPast"):SetData(value[13])
			-- ����� ���� ������
			crInfo:AddNode("Balans"):SetData(value[12])

		crInfo:AddNode("Payments")
		crInfo:AddNode("MissPayInfos")

		--��������� �����������--
		if value[18]~= "" then

			local ensure=
			{
			["01"]= "����������",
			["02"]= "������ � �������",
			["03"]= "���������� ��������",
			["11"]= "������������",
			["12"]= "������������ ������������",
			["13"]= "������ � ����������",
			["14"]= "�������������������� ������������ � ������",
			["15"]= "���������������� ������������",
			["16"]= "�������� ��������� ������� (������� ������� � ����.)",
			["17"]= "�����",
			["18"]= "�������",
			["19"]= "�������� ��������, ���������",
			["20"]= "�����",
			}

			node.CreditInfo:AddNode("Ensures")
			local fens = node.CreditInfo.Ensures:AddNode("Ensure")
			fens:AddNode("Ensure"):SetData(value[18])
			fens:AddNode("CollateralValue"):SetData(value[34])
			fens:AddNode("Currency"):SetData(value[17])
			fens:AddNode("CollateralDate"):SetData(dataFormat(value[35]))
			fens:AddNode("EnsureDateEnd"):SetData(dataFormat(value[36]))
		end
		------------------------


		local closeCreditTrue=
		{
			["14"]= "00",
			["13"]= "00",
			["12"]= "00",
		}

		local closeCreditReason=
		{
			["14"]= '3',
			["13"]= '1',
			["12"]= '2',
		}

		--����������� ����
		if closeCreditReason[value[8]] == "3" then
			local Righr = node:AddNode("RightOfClaim")
			Righr:AddNode("Date"):SetData(dataFormat(value[10]))
			Righr:AddNode("Person")
			Righr.Person:AddNode("Name"):SetData(dataFormat(value[38]))
			Righr.Person:AddNode("RegistrationID"):SetData(value[39])
			Righr.Person:AddNode("INN"):SetData(value[40])
			Righr.Person:AddNode("SNILS"):SetData(value[41])
		end

		--���������� � �������� �������--
		if closeCreditTrue[value[8]] == "00"	then
			node.CreditInfo:AddNode("CloseCredit")
			node.CreditInfo.CloseCredit:AddNode("CreditClosedDate")
			node.CreditInfo.CloseCredit.CreditClosedDate:SetData(dataFormat(value[19]))
			node.CreditInfo.CloseCredit:AddNode("CreditClosedReason")
			node.CreditInfo.CloseCredit.CreditClosedReason:SetData(closeCreditReason[value[8]])
		end


	else
		if value[5] == "6" then
			node.TypeBorrower:SetData("4")
			node:AddNode("BankGuaranty")
			node.BankGuaranty:AddNode("GuarantyNumber")
			node.BankGuaranty.GuarantyNumber:SetData(value[3])
			node.BankGuaranty:AddNode("GuarantyDateStart")
			node.BankGuaranty.GuarantyDateStart:SetData(dataFormat(value[6]))
			node.BankGuaranty:AddNode("GuarantyDateClosed")
			node.BankGuaranty.GuarantyDateClosed:SetData(dataFormat(value[33]))
			node.BankGuaranty:AddNode("GuarantySum")
			node.BankGuaranty.GuarantySum:SetData(value[32])
			node.BankGuaranty:AddNode("GuarantyCurrency")
			node.BankGuaranty.GuarantyCurrency:SetData(value[17])
			node.BankGuaranty:AddNode("Volume")
			node.BankGuaranty.Volume:SetData(value[31])
			--[=[node.BankGuaranty:AddNode("Date")
			node.BankGuaranty.GuarantyDateClosed:SetData(dataFormat(value[33]))
			node.BankGuaranty:AddNode("Reason")
			node.BankGuaranty.GuarantyCurrency:SetData(value[17])
--]=]
		else
			if value[5] == "5" then
				node.TypeBorrower:SetData("3")
				node:AddNode("GuaranteeInfo")
				node.GuaranteeInfo:AddNode("CreditType")
				node.GuaranteeInfo.CreditType:SetData(value[4])
				node.GuaranteeInfo:AddNode("CreditBorrowerNumber")
				node.GuaranteeInfo.CreditBorrowerNumber:SetData(value[3])
				node.GuaranteeInfo:AddNode("GuaranteeNumber")
				node.GuaranteeInfo.GuaranteeNumber:SetData(value[3])
				node.GuaranteeInfo:AddNode("GuaranteeDateStart")
				node.GuaranteeInfo.GuaranteeDateStart:SetData(dataFormat(value[6]))
				node.GuaranteeInfo:AddNode("GuaranteeDateClosed")
				node.GuaranteeInfo.GuaranteeDateClosed:SetData(dataFormat(value[29]))
				node.GuaranteeInfo:AddNode("GuaranteeSum")
				node.GuaranteeInfo.GuaranteeSum:SetData(value[28])
				node.GuaranteeInfo:AddNode("GuaranteeCurrency")
				node.GuaranteeInfo.GuaranteeCurrency:SetData(value[17])
				node.GuaranteeInfo:AddNode("Volume")
				node.GuaranteeInfo.Volume:SetData(value[27])
				node.GuaranteeInfo:AddNode("FullCurrentCreditSum")
				node.GuaranteeInfo.FullCurrentCreditSum:SetData(value[25])
				node.GuaranteeInfo:AddNode("DateLastPayment")
				node.GuaranteeInfo.DateLastPayment:SetData(dataFormat(value[7]))
			end
		end
	end
	Log("write TR")
	return true, false, node

end

function ReturnTrue()
	return true
end


function Log(m)
--	local ok,err =	appendfile(logfile,m.."\r\n")
--	if not ok then MsgBox(render{err,logfile}) error"AsDASDASD" end
end

function Line_From(file)
	if not IO.File.Exists(file or "") then return {} end
	local tS = {}
	local f=io.input(file)
	for line in f:lines() do
		table.insert(tS,line)
	end
	f:close ()
	return tS
end

function Get_Line(filename, line_number)
	local s
	pcall(do
		local f=io.input(filename)
		for i=1,tonumber(line_number) do
			s=f:read()
		end
		f:close ()
	end)
	return s
end



function Read_Header(line)
	local template= string.char(09)
	local header= line:split("\t")
	local throw= "error in header"
	if #header<9 then
		if #header>5 then
			local t= {}
			if header[1] == "TUTDF" then t["Name_File"]= true
				else t["Name_File"]= false end

			if header[2]:starts("6") then t["Version"]= header[2]
			else t["Version"]= false end

			if header[3] == "20191001" then t["Start_Date"]= true
				else t["Start_Date"]= false end
			if string.len(header[4]) == '12' then t["ClientName"]= header[4]
				else t["ClientName"]= false end
			if string.len(header[5]) == '8' then t["Cycle_Identification"]= true
				else t["Cycle_Identification"]= false end
			if string.len(header[6]) == "8" then t["Req_Date"]= header[6]
				else t["Req_Date"]= false end
			if string.len(header[7]) == '8' then t["ClientPwsrd"]= true
				else t["ClientPwsrd"]= false end
			for i,value in ipairs(t) do
				if value == false then Log(throw.."/n") Log(t.."/n") return throw
				end
			end
		else
			Log(throw.."/n".."--<6 tabs--")	return throw
		end
	else
		Log(throw.."/n".."-->8 tabs--") return throw
	end
	head = header
	return header
end

function Read_ID(line)
	local template= string.char(09)
	local read_string= line:split(template)
	--if #read_string<6 then
	if #read_string<6 then
		Log "���������������� ������� (ID) ����� ��������� < 6\r\n"
		return "���������������� ������� (ID) ����� ��������� < 6"
	end
	if read_string[2]=="" then return "���������������� ������� (ID). �� ������ �������� ���� ��� ID[2] - " end
	if read_string[2]=="21" then
		read_string[3]=read_string[3]:swap(" ","")
		read_string[4]=read_string[4]:swap(" ","")
		read_string[6]=read_string[6]:trim()
		if #read_string[3]~=4 then return "���������������� ������� (ID). �� ������ �������� ���� ����� �����[3] - "..read_string[3] end
		if #read_string[4]~=6 then return "���������������� ������� (ID). �� ������ �������� ���� ����� ���������[4] - "..read_string[4] end
	end
	if read_string[2]=="33" then
		if read_string[5]~="" then return "���������������� ������� (ID). �� ������ �������� ���� ����� �����[5] - "..read_string[3] end
	end
	return read_string
end

function Read_PA(line)
	local template= string.char(09)
	local read_string= line:split(template)
	if #read_string<7 then
		Log "������� ����������� ���������� ������������ (�������) (PA) ����� ��������� < 7\r\n"
		return "������� ����������� ���������� ������������ (�������) (PA) ����� ��������� < 7"
	end
	return read_string
end

function Read_NA(line)
	local template= string.char(09)
	local read_string= line:split(template)
	if #read_string<13 then
		Log "������� ����� (NA) ����� ��������� < 13\r\n"
		return "������� ����� (NA) ����� ��������� < 13"
	end
	if read_string[2]=="" then return "������� ������ (NA). ����������� ���� �������[2]" end
	read_string[2]=read_string[2]:trim()
	if read_string[4]=="" then return "������� ������ (NA). ����������� ���� ���[4]" end
	read_string[4]=read_string[4]:trim()
	if read_string[6]=="" then return "������� ������ (NA). ����������� ���� ���� ��������[6]" end
	if read_string[7]=="" then return "������� ������ (NA). ����������� ���� ����� ��������[7]" end
	return read_string
end

function Read_BU(line)
	local template= string.char(09)
	local read_string= line:split(template)
	if #read_string<25 then
		Log "������� ����������� (BU) ����� ��������� < 25\r\n"
		return "������� ����������� (BU) ����� ��������� < 25"
	end
	return read_string
end

function Read_AD(line)
	local template= string.char(09)
	local read_string= line:split(template)
	if #read_string<16 then
		Log "������� ������ (AD). ����� ��������� < 16\r\n"
		return "������� ������ (AD). ����� ��������� < 16"
	end
	if read_string[5]=="" then read_string[5]="00" end
	if read_string[8]=="" then return "������� ������ (AD). ����������� ���� ��������������[8]" end
	if read_string[11]=="" then return "������� ������ (AD). ����������� ���� ����� ����[11]" end
	return read_string
end

function Read_PN(line)
	local template= string.char(09)
	local read_string= line:split(template)
	if #read_string<3 then
		Log "������� �������� (PN). ����� ��������� < 3\r\n"
		return "������� �������� (PN)) ����� ��������� < 3"
	end
	return read_string
end

function Read_CL(line)
	local template= string.char(09)
	local read_string= line:split(template)
	local throw= "error in CL"
	if #read_string<7 then
		Log "������� �������������� ������ (CL) ����� ��������� < 7\r\n"
		return "������� �������������� ������ (CL) ����� ��������� < 7"
	end
	return read_string
end

function Read_GR(line)
	local template= string.char(09)
	local read_string= line:split(template)
	if #read_string<6 then
		Log "������� �������������� ���������� (GR) ����� ��������� < 6\r\n"
		return "������� �������������� ���������� (GR) ����� ��������� < 6"
	end
	return read_string
end

function Read_False(line)
	return nil
end

function Read_BG(line)
	local template= string.char(09)
	local read_string= line:split(template)
	if #read_string<7 then
		Log "������� �������������� ���������� �������� (BG) ����� ��������� < 7\r\n"
		return "������� �������������� ���������� �������� (BG) ����� ��������� < 7"
	end
	return read_string
end

function Read_TR(line)
	local template= string.char(09)
	local read_string= line:split(template)
	if #read_string<49 then
		Log "������� ������� (TR) ����� ��������� < 49\r\n"
		return "������� ������� (TR) ����� ��������� < 49"
	end
	if read_string[37]=="N" then read_string[37]="" end
	if read_string[17]=="" then read_string[17]="RUB" end
	if read_string[25]=="" then return "������� ������� (TR) ������� ������������� [25] ������" end
	if read_string[5]=="" then return "������� ������� (TR) ��������� � �����[5] ������" end
	if read_string[6]=="" then return "������� ������� (TR) ���� �������� �����/���� ���������� �������� ��������������/���������� ��������[6] ������" end



	--���������� ������������� ��������
	if (read_string[5]=="5" or read_string[5]=="6" or read_string[5]=="1") and 20191029<tonumber(read_string[6]) then
		if read_string[50]=="" or #read_string[50]==0 then return "������� ������� (TR) ���������� ������������� ��������[50] �� ����� ��������" end
	end

	if read_string[5]~="5" then -- ���� �� ����������

		if read_string[7]=="" then return "������� ������� (TR) ���� ���� ��������� �������[7] ������" end
		if read_string[11]=="" then return "������� ������� (TR) ���� ����� �������/�������� ����� �������[11] ������" end
		if read_string[12]=="" then return "������� ������� (TR) ���� ������[12] ������" end
		if read_string[13]=="" then return "������� ������� (TR) ���� ���������[13] ������" end
		if read_string[20]=="" then return "������� ������� (TR) ���� ���� ���������� �������[20] ������" end
		if read_string[19]=="" then read_string[19]=read_string[20] end
		if read_string[21]=="" then return "������� ������� (TR) ���� ���� ��������� ������� ���������[21] ������" end
		if read_string[25]=="" then return "������� ������� (TR) ���� ������� �������������[25] ������" end
		if read_string[7]=="19000102" then
			if read_string[43]=="" then read_string[43]=read_string[11] end
			if read_string[44]=="" then read_string[44]=0 end
			if read_string[45]=="" then read_string[45]=0 end

			if read_string[46]=="" then read_string[46]=0 end
			if read_string[47]=="" then read_string[47]=0 end
			if read_string[48]=="" then read_string[48]=0 end
		else
			if read_string[43]=="" then return "������� ������� (TR) ���� ���������� ������� �������� �� 19000102. ���� ������� ������������� �� ��������� ����� �� ���� ���������� �������[43] ������" end
			if read_string[44]=="" then return "������� ������� (TR) ���� ���������� ������� �������� �� 19000102. ���� ������� ������������� �� ��������� �� ���� ���������� �������[44] ������" end
			if read_string[45]=="" then return "������� ������� (TR) ���� ���������� ������� �������� �� 19000102. ���� ����� ���������� ������ �������� � ���� ����������� ���������� � �������� � ������� ������� ������������� �� ���� ���������� �������[45] ������" end
			if read_string[46]=="" then return "������� ������� (TR) ���� ���������� ������� �������� �� 19000102. ���� ������������ ������������� �� ��������� ����� �� ���� ���������� �������[46] ������" end
			if read_string[47]=="" then return "������� ������� (TR) ���� ���������� ������� �������� �� 19000102. ���� ������������ ������������� �� ��������� �� ���� ���������� �������[47] ������" end
			if read_string[48]=="" then return "������� ������� (TR) ���� ���������� ������� �������� �� 19000102. ���� ����� ������������ ��������, � ����� ����� ��������� (������, ����) � ���� ����������� ���������� � �������� �� ���� ���������� �������[48] ������" end
		end

		-- �������� ������� � ������
		if read_string[34]=="0" then read_string[34]="" end
		if read_string[34]~="" or read_string[35]~="" or read_string[36]~="" or read_string[18]~="" then
			if read_string[18]=="" then return "������� ������� (TR) ��� ������[18] ������" end
			if read_string[34]=="" then return "������� ������� (TR) ��������� ��������� ������[34] ������" end
			if read_string[35]=="" then return "������� ������� (TR) ���� ������ ��������� ������[35] ������" end
			if read_string[36]=="" then return "������� ������� (TR) ���� �������� �������� ������[36] ������" end
		end




	end
	return read_string
end

function Read_LE(line)
	local template= string.char(09)
	local read_string= line:split(template)
	if #read_string<8 then
		Log "������� ����������� ������ (LE) ����� ��������� < 8\r\n"
		return "������� ����������� ������ (LE) ����� ��������� < 8"
	end
	return read_string
end

function Read_BK(line)
	local template= string.char(09)
	local read_string= line:split(template)
	if #read_string<8 then
		Log "������� ������������ ������ (BK) ����� ��������� < 8\r\n"
		return "������� ������������ ������ (BK) ����� ��������� < 8"
	end
	return read_string
end

function Read_BC(line)
	if #read_string<12 then
		Log "������� ������������ ������� (BC) ����� ��������� < 8\r\n"
		return "������� ������������ ������� (BC) ����� ��������� < 8"
	end
	return read_string
end

function Read_IP(line)
	local template= string.char(09)
	local read_string= line:split(template)
	if #read_string<19 then
		Log "������� ��������������� ������ (IP) ����� ��������� < 19\r\n"
		return "������� ��������������� ������ (IP) ����� ��������� < 19"
	end
	--if typePrson=="1" and read_string[8]=="" then return "������� ��������������� ������ (IP). ���� ������ �������������� ������[8] ������" end
	return read_string
end

function Read_TRLR(line)
	local template= string.char(09)
	local read_string= line:split(template)
	if #read_string<2 then
		Log "������� �������� (TRLR) ����� ��������� < 2\r\n"
		return "������� �������� (TRLR) ����� ��������� < 2"
	end
	return read_string
end

function Read_First_Data_Blok(line)
	if line then
		local template= string.char(09)
		local read_string= line:split(template)
		return read_string[1]
	end
end

function Read_ERROR(line)
	local template= string.char(09)
	local read_string= line:split(template)
	local throw= "error in ERROR"
	if #read_string<4 then
		if #read_string>2 then return read_string

		else
			Log(throw.."/n".."--<3 tabs--")	return throw
		end
	else
		Log(throw.."/n".."-->3 tabs--") return throw
	end
	return read_string
end


-- ����� ���� ��� ����������� ��������� � ������� � �� ����������� �������� (�� ������)
-- ���������� ������ � ������ ������ � ������� � ������ ��, � ������ ������ nil
function Line_Seter(line)
	if not line then return nil,"fLine_Seter - line is nil" end -- �����
	local read = Read_First_Data_Blok(line)
	if not read then return nil,"fLine_Seter - read is nil" end -- �����
	if (read == "TRLR") then return nil,"fLine_Seter - TRLR" end -- �����
	if (read == "TUTDF") then return nil,"fLine_Seter - TUTDF" end -- �����
	local teg,err = Get_TUTDF_TEG(line)
	if not teg or not action[teg] then return "�� ������ �������� teg "..render(teg) end
	return action[teg](line)
end

function Write_Person(Person, line, err)
	--Log('________Person____'..render{Person})
	if err then return false, err, nil, line end
	--MsgBox(render(head))
	local xml= XML.DOM.CreateXML()
	--MsgBox(render(xml))
	local TOBKI= xml:AddNode("TOBKI")
	TOBKI:AddNode("IDSchema")
	TOBKI.IDSchema:AddData("3")
	TOBKI:AddNode("PackID"):AddData(DateTime.Now:ToString"%X")
	TOBKI:AddNode("CreatePackDate")
	TOBKI.CreatePackDate:AddData(dataFormat(head[6]))
	TOBKI:AddNode("RelevanceDate")
	TOBKI.RelevanceDate:AddData(dataFormat(head[6]))
	TOBKI:AddNode("PartnerID")
	TOBKI.PartnerID:SetData(head[4])
	--[=[TOBKI:AddNode("DistributorID")
	TOBKI.DistributorID:AddData(head[4])
--]=]
	TOBKI:AddNode("ContractTerminate")
	TOBKI.ContractTerminate:AddData("0")
	TOBKI:AddNode("TypeBorrower")
	TOBKI.TypeBorrower:AddData("3")
	TOBKI:AddNode("RightOfClaim")
	TOBKI:AddNode("CreditorType")
	TOBKI:AddNode("AnotherOrganizationTypeOfCredit")
    --MsgBox(render(TOBKI:ToString(true)))
    local table_writer = {}
    table_writer[1] = "ID"
    table_writer[2] = "NA"
    table_writer[3] = "BU"
    table_writer[4] = "AD"
    table_writer[5] = "PN"
    table_writer[6] = "TR"
    table_writer[7] = "CL"
    table_writer[8] = "GR"
    table_writer[9] = "BG"
    table_writer[10] = "PA"
    table_writer[11] = "LE"
    table_writer[12] = "BK"
    table_writer[13] = "BC"
    table_writer[14] = "IP"
	--"GR"
    local itaretor = 1
    while table_writer[itaretor] do
        for i = 1, 99 do
            if i>9 then
                key = table_writer[itaretor]..i
            else
                key = table_writer[itaretor].."0"..i
            end
            if (Person[key]) then
				for oo, va in pairs(Person[key]) do
					local cva = va
					local a= 0
					for S in string.gmatch(cva, ",") do -- ���������� ��������, �������, ��� ������ ������, ���������� ��������� ��������� ������� � S
						a= a+1
					end;
					cva = cva:swap(",",".")
					cva = tonumber(cva)
					if a>0 then
						if not (cva==nil) then
							if not (cva == "") then
								Person[key][oo] = tostring(cva)
							end
						end
					end
				end
                ok, err, TOBKI= write_string(Person[key], TOBKI)
				if TOBKI==nill then Log(xrender('key|',key,'|person|',Person[key])) end
            else
                break
            end
        end
        itaretor = itaretor + 1
    end
	TOBKI:DeleteEmptyNodes()
	return true, nill, TOBKI, line
end

function Get_TUTDF_TEG(line)
	if not line or #line<=2 then return nil,"fGet_TUTDF_TEG not correct val - "..render(line) end
	return string.sub(line,1,1)..string.sub(line,2,2)
end

function Read_Person(line, file)
	local PersonFlag= true
	local Person= {}
	local ok,res,err=pcall(do
		while PersonFlag do
			local Step= Get_Line(file, line)
			local Set= Get_TUTDF_TEG(Step)
			if Set:upper() == "TRLR" then break end
			local StrName= Read_First_Data_Blok(Step)
			local lSet = Line_Seter(Step)
			if type(lSet)=="string" then return nil,lSet end -- ��������� ������
			if type(lSet)=="table" then
				Person[StrName]= {}
				for i,value in ipairs(lSet) do
					Person[StrName][i]= tostring(value)
				end
				local fl = PersonEndings(Set)
				if fl then PersonFlag = false end
				line = line+1
				--return true
			end
		end
	end)

	if not ok or err then return nil, line, err or res end
	return Person, line, tError
end

function Save_Xml(OK, err, Xml, line)
	if not OK then Log(err)
	else
			Xml:WriteXml("XML_FilePath..File"..TUTDF_FilePath..Line)
	end
	return line
end

function Return_Xml(OK, err, Xml, line)
	--Log(render{OK, err, Xml, line})
	if err then return {err,line},line end
	return Xml:ToString(true), line
end

function write_string(parsed_string, tobki)
	--MsgBox(render{parsed_string[1]})
	if (#parsed_string>1) and (parsed_string) then
		--MsgBox(render(tostring(parsed_string[1])))
		local LineName = string.sub((parsed_string[1]), 1, 2)
		return write_action[LineName](tobki, parsed_string)
	end
end

local LineNumber=1
local TUTDF_FilePath=[[C:\290130313]]
local XML_FilePath= [[C:\saw\]]

function TUTDF_TO_XML_Protected( TUTDF_FilePath)
	setGlobal()
	local XML_pack
	local tfile, XML_pack = pcall(TUTDF_TO_XML, TUTDF_FilePath)
	if tfile then return XML_pack
	else MsgBox("Eroor")
	end
end



function TUTDF_TO_XML_2( TUTDF_FilePath, logNm)
	setGlobal(logNm, TUTDF_FilePath)
	local LineNumber=1
	local XML_pack={}
	local tReadStr= Line_From(TUTDF_FilePath)
	local header = Read_Header(tReadStr[1])
	for i=1,#tReadStr do


	end
	if #ReadStr>1 then

		LineNumber=LineNumber + 1
		if (#ReadStr-LineNumber)>=3 then
			local calc = #ReadStr-LineNumber
			while (calc)>4 do

				ok,XMl,LineNumber = pcall(do return Return_Xml(Write_Person(Read_Person(LineNumber, TUTDF_FilePath))) end )
				--Log(render{ok,XMl,LineNumber,type(XMl)})

				Log(render{ok,XMl,LineNumber})
				if type(XMl)=="table" then
					for i=1,100 do
						LineNumber=LineNumber+1
						local str=Get_Line(TUTDF_FilePath, LineNumber)
						local seg=Read_First_Data_Blok(str)
						if seg=="ID01" or seg=="TRLR" then break end
					end
				end

				Log("  ������ �� ������"..render(LineNumber))
				calc = #ReadStr-LineNumber
				table.insert(XML_pack,XMl )
			end
			return XML_pack
		else
			local throw= "File is bad"
			return(throw)
		end
	else
		local throw= "File is empty"
		return(throw)
	end
end



function TUTDF_TO_XML( TUTDF_FilePath, logNm)
	setGlobal(logNm, TUTDF_FilePath)
	local LineNumber=1
	local XML_pack={}
	local ReadStr= Line_From(TUTDF_FilePath)
	if #ReadStr>1 then
		local header= Read_Header(Get_Line(TUTDF_FilePath, LineNumber))
		LineNumber=LineNumber + 1
		if (#ReadStr-LineNumber)>=3 then
			local calc = #ReadStr-LineNumber
			while (calc)>4 do

				ok,XMl,LineNumber = pcall(do return Return_Xml(Write_Person(Read_Person(LineNumber, TUTDF_FilePath))) end )
				--Log(render{ok,XMl,LineNumber,type(XMl)})
				if not LineNumber then
					calc=1
					Log(render{ok,XMl,LineNumber})
				else
					if type(XMl)=="table" then
						for i=1,100 do
							LineNumber=LineNumber+1
							local str=Get_Line(TUTDF_FilePath, LineNumber)
							local seg=Read_First_Data_Blok(str)
							if seg=="ID01" or seg=="TRLR" then break end
						end
					end
					calc = #ReadStr-LineNumber
				end

				Log("  ������ �� ������"..render(LineNumber))
				table.insert(XML_pack,XMl)
			end
			return XML_pack
		else
			return{"File is bad: \r\n"..table.concat(ReadStr,"\r\n")}
		end
	else
		return{"File is empty"}
	end
end

function TUTDF_TO_XML_SAVE( TUTDF_FilePath, XML_FilePath )
	setGlobal()
	LineNumber=1
	local ReadStr= Line_From(TUTDF_FilePath)
	if #ReadStr>1 then
		local header= Read_Header(Get_Line(TUTDF_FilePath, LineNumber))
		if (#ReadStr-LineNumber)>3 then
			local calc= #ReadStr-LineNumber
			while (calc)>3 do
			LineNumber= Save_Xml(Write_Person(Read_Person(LineNumber)))
			calc= #ReadStr-LineNumber
			end
		else
			local throw= "File is bad"
			Log(throw)
		end
	else
		local throw= "File is empty"
		Log(throw)
	end
end
