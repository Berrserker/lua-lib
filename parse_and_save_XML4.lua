
module(... ,package.seeall) --Удалить объявление модуля, если скрипт вызывается из интернет-компонента или планировщика.
require("xsdInputXMLCreditHistoy_schema3",true)
local ckkiScript=require("CKKI",true)
local baseIC=GetBank():GetBase("ИС")
local baseFL=GetBank():GetBase("ФЛ")
local baseUL=GetBank():GetBase("ЮЛ")
local baseAD=GetBank():GetBase("АД")
local baseZV=GetBank():GetBase("ЗВ")
local baseDC=GetBank():GetBase("ДК")
local baseТФ=GetBank():GetBase("TF")
local baseNC=GetBank():GetBase("NC")
local basePL=GetBank():GetBase("PL")
local baseEN=GetBank():GetBase("EN")
local baseCP=GetBank():GetBase("СР")
local basePR=GetBank():GetBase("PR")
local baseBK=GetBank():GetBase("БК")
local baseBF=GetBank():GetBase("BF")
local baseBG=GetBank():GetBase("BG")
local baseGI=GetBank():GetBase("ПР")
local baseAR=GetBank():GetBase("AR")

local tNewRec={}


local function delRercord(tRec)
	if #tRec==0 then return end
	for _,r in ipairs(tRec) do
		local base=r.Base
		local rS=RecordSet ({r.SN},base)
		base:DeleteRecords(rS) -- такое удаление, заберает с собой связи с базами
	end
end

local function addRecord(b)
	local r=b:AddRecord()
	tNewRec[#tNewRec+1]=r
	return r
end

local function addVal(r,t)
	if not r then return nil, "Пустая запись: "..render(t) end
	local base=r.Base
	local r=base:GetRecord(r.SN) -- Перечитываем запись, а то можем потерять линки
	for num,val in pairs(t) do
		if not val then continue end -- в случае если false
		val=val:upper()
		local field = base:GetField(num)
		if not field then return nil, "Нет поля с номером "..num.." в базе "..base.Code end
		if field.TestStatus(8192) then -- если поле множественное то мы объединяем значение
			val = table.iunion(r:GetValue(num,0),{val})
		end
		r:SetValue(num,val) -- переписывем новым значением, необходимо для корректировки, ранее не верно переданной информации
	end
	r:Update()
	return r
end

local function findDOC(rs,id)
	if rs.Count==0 then return nil end
	local rsC=rs:Clone()
	rsC:StringRequest("ОТ ДК01 2 РВ '"..id.."'")
	if rsC.Count==0 then return nil end
	return rsC:GetRecordByIndex(1)
end

local function findAdr(rs,tp,region,location,houseNumber,description)
	if rs.Count==0 then return nil end


	local rsC=rs:Clone()
	if description and description~="" then
		rsC:StringRequest("ОТ АД01 9 РВ "..tp.." И 21 РВ '"..description.."'")
	else
		if not region or region=="" or not location or location=="" or not houseNumber or houseNumber=="" then return nil end
		rsC:StringRequest("ОТ АД01 9 РВ "..tp.." И 2 РВ "..region.." И 4 РВ '"..location.."' И 6 РВ '"..houseNumber.."'")
	end
	if rsC.Count==0 then return nil end
	return rsC:GetRecordByIndex(1)
end

function parse(rec,notUseXSD,testMode)
	--MsgBox"OK"
	local recCKKI={} -- набор документов для передачи в цкки
	tNewRec={} -- обнуляем таблицу записей
	local ti=table.isempty -- для ускарения
	if tolua.type(rec)~='Record' then return nil, "Не правильный вызов функции parseAndSaveXML. На вход должен подаваться объект Rrcord базы РЕ " end
	if rec.Base.Code~='РЕ' then return nil, "Не правильный вызов функции parseAndSaveXML. Запсиь должна быть базы РЕ(Реестр XML)" end
	--MsgBox(render(rec.SN))
	local ok,res = pcall(do

		local content=rec:GetValue2(4) or error{errText="Не корректное значение поля №4 записи "..tostring(rec.SN).." базы РЕ (Реестр XML)"}
		local tParse=IO.Path.Parse(content)
		if tParse and type(tParse)=='table' and tParse.FileName then -- значит content это ссылка на файл.
			content=readfile(content) or readfile(rec:GetValue(16)) or error{errText="Не удалось прочитать XML файл: "..content.. ". Не корректное значение поля №4 записи "..tostring(rec.SN).." базы РЕ (Реестр XML)"}
			if content=="" then error{errText="Не удалось получить содержание XML. Запись "..tostring(rec.SN).." базы РЕ (Реестр XML)"} end
		end

		local d, err = XML.DOM.Parse (content)
		if not d then error{errText="Ошибка создания dom объекта."..render{dom, err}.. ". Не корректное значение поля №4 записи "..tostring(rec.SN).." базы РЕ (Реестр XML)", errType=0,} end

		----- Проверка валидности по XSD -----
		if not notUseXSD then
			local res, errData = ValidateXML (content, xsdInputXMLCreditHistoy_schema3.XSD, "")
			if not res then error{errText="Произошла ошибка при валидации, не связанная с валидацией:\r\n"..errData..". Запись: "..rec.SN,errType=10} end
			local errText=""
			if res and errData and #errData>0 then
				for _, err in ipairs(errData) do
					errText = errText .. "Cтрока: " .. err.line .. "; столбец: "..err.column.."; сообщение: "..err.message.."\r\n"
				end
				local f=content:match("<Surname>(.-)</Surname>") or ""
				local i=content:match("<FirstName>(.-)</FirstName>") or ""
				local dr=content:match("<DateOfBirth>(.-)</DateOfBirth>") or ""
				error{errText=f.." "..i.." "..dr.." ХМЛ не верного формата. \r\n "..errText,errType=10}
			end
		end
		--------------------------------------

		-------- пост валидация данных --------
		-- порверка корректности источника
		local PartnerID=d.PartnerID'$v'
		local DistributorID=d.DistributorID'$v'
		PartnerID=PartnerID:swap("PRT040814",""):swap("PRT040815","")
		if #PartnerID<6 then error{errText="Не верный источник: "..d.PartnerID'$v',errType=10}  end
		if (baseIC:StringRequest("ОТ ИС01 3 РВ "..PartnerID)).Count==0 then error{errText="Не известный источник: "..PartnerID,errType=10} end




		--!! FIX ME -- доделать осталоьные проверки
		---------------------------------------

		-- заполняем недостающие поля в базе Реестр XML --
		local IDD = rec:GetValue(3)
		IDD = IDD:split("#")[3]:split('PREFIX')[1]:lower()

		rec:SetValue(8,d.PackID'$v')
		rec:SetValue(9,d.CreatePackDate'$v')
		rec:SetValue(11,PartnerID)
		rec:SetValue(21,DistributorID)
		rec:Update()

		if testMode then rec:SetValue(7,1) rec:Update() return end -- если тест то делаем соотв. отметку и дальше ни чего не делаем

		--------------------------------------------------

		--Определяем запись с заемщиком, в случае необходимости создаем новую или корректируем старую
		local recSubject
		local tRec={}

		if not ti(d.NaturalPerson) then -- у нас физик
			-- проверка на хитрожопость
			if #d.NaturalPerson.Surname'$v':trim()==0 then error{errText="Surname состоит из пробелов.",errType=10} end
			if #d.NaturalPerson.FirstName'$v':trim()==0 then error{errText="FirstName состоит из пробелов.",errType=10} end

			-- ищем запись или создаем новую
			recSubject=(do
				local recSet=baseFL:StringRequest("ОТ ФЛ01 1 РВ '"..d.NaturalPerson.Surname'$v'.."' И 2 РВ '"..d.NaturalPerson.FirstName'$v'.."' И 4 РВ "..d.NaturalPerson.DateOfBirth'$v')
				if recSet.Count==0 then return nil end
				-- сверяем отчество, елси есть
				if d.NaturalPerson.PatronymicName'$v' and d.NaturalPerson.PatronymicName'$v'~="" then
					recSet:StringRequest("ОТ ФЛ01 3 РВ '"..d.NaturalPerson.PatronymicName'$v'.."'")
					if recSet.Count==0 then return nil end
				end
				return recSet:GetRecordByIndex(1)
			end)() or addRecord(baseFL)


			-- модернизация/сохраняем самого физика
			local ok,err=addVal(recSubject,
				{
				[1]=d.NaturalPerson.Surname'$v',
				[2]=d.NaturalPerson.FirstName'$v',
				[3]=d.NaturalPerson.PatronymicName'$v',
				[4]=d.NaturalPerson.DateOfBirth'$v',
				[5]=d.NaturalPerson.PlaceOfBirth'$v',
				[13]=d.NaturalPerson.INN'$v',
				[14]=d.NaturalPerson.Insurance'$v',
				[11]=(do
					local previousFIO=(d.NaturalPerson.OldSurname'$v' or "").."|"..(d.NaturalPerson.OldFirstName'$v' or "").."|"..(d.NaturalPerson.OldPatronymicName'$v' or "")
					if #previousFIO==2 then previousFIO="" end
					return previousFIO
				end)(),
				[23]=d.NaturalPerson.SubjectCode'$v',
				[17]=(do
					local ipInfo=(d.NaturalPerson.DateRegisterIP'$v' or "").."|"..(d.NaturalPerson.OGRNIP'$v' or "")
					if #ipInfo==1 then ipInfo="" end
					return ipInfo
				end)(),
				[20]=(do
					local incapableInfo=(d.NaturalPerson.IncapableInformation.Date'$v' or "").."|"..(d.NaturalPerson.IncapableInformation.Resolute'$v' or "")
					if #incapableInfo==1 then incapableInfo="" end
					return incapableInfo
				end)(),

				[203]=PartnerID,
				[204]=DistributorID,
				[19]=(do
					local missPayInfo=(d.CreditInfo.DateActual'$v' or "").."|"..(d.CreditInfo.DatePayment'$v' or "").."|"..(d.CreditInfo.DateFirstMissPayment'$v' or "").."|"..(d.CreditInfo.DateSecondMissPayment'$v' or "")
					if #missPayInfo==3 then missPayInfo="" end
					return missPayInfo
				end)()
				}
			)
			if not ok then error{errText=err, errType=10} end
			recSubject.Base:AddLink (recSubject.SN, 353, "РЕ", rec.SN) --связываем с реестром XML

			-- Сохранение/добавление документа
			local recSetDoc=recSubject:GetValue(352,"ДК")
			if not ti(d.NaturalPerson.PassportRF) then
				for i=1,d.NaturalPerson.PassportRF'$n' do
					local recDoc=findDOC(recSetDoc,d.NaturalPerson.PassportRF[i].SeriesAndNumber'$v') or addRecord(baseDC)
					--MsgBox()
					local ok,err=addVal(recDoc,
						{
							[1]="1",
							[2]=d.NaturalPerson.PassportRF[i].SeriesAndNumber'$v',
							[4]=d.NaturalPerson.PassportRF[i].IssueDate'$v',
							[5]=d.NaturalPerson.PassportRF[i].IssueInfo'$v'
						}
					)
					if not ok then error{errText=err, errType=10} end
					-- линки
					recDoc.Base:AddLink (recDoc.SN, 300, "ФЛ", recSubject.SN) --связываем с реестром лицом
					recDoc.Base:AddLink (recDoc.SN, 310, "РЕ", rec.SN) --связываем с реестром XML
					table.insert(recCKKI,recDoc)
				end
			end
			if not ti(d.NaturalPerson.AddDocument) then
				for i=1,d.NaturalPerson.AddDocument'$n' do
					local recDoc=findDOC(recSetDoc,d.NaturalPerson.AddDocument[i].SeriesAndNumber'$v') or addRecord(baseDC)
					local ok,err=addVal(recDoc,
						{
							[1]=d.NaturalPerson.AddDocument[i].Type'$v',
							[2]=d.NaturalPerson.AddDocument[i].SeriesAndNumber'$v',
							[4]=d.NaturalPerson.AddDocument[i].IssueDate'$v',
							[5]=d.NaturalPerson.AddDocument[i].IssueInfo'$v'
						}
					)
					if not ok then error{errText=err, errType=10} end
					-- линки
					recDoc.Base:AddLink (recDoc.SN, 300, "ФЛ", recSubject.SN) --связываем с реестром лицом
					recDoc.Base:AddLink (recDoc.SN, 310, "РЕ", rec.SN) --связываем с реестром XML
					table.insert(recCKKI,recDoc)
				end
			end

			-- модернизация/добовление адреса регистрации
			local recSetAdr=recSubject:GetValue(350,"АД")
			local recAdr=findAdr(recSetAdr,"1",d.NaturalPerson.RegistrationAddress.Region'$v',d.NaturalPerson.RegistrationAddress.Location'$v',d.NaturalPerson.RegistrationAddress.HouseNumber'$v',d.NaturalPerson.RegistrationAddress.Description'$v') or addRecord(baseAD)
			local ok,err=addVal(recAdr,
				{
					[10]=d.NaturalPerson.RegistrationAddress.PostalCode'$v',
					[1]=d.NaturalPerson.RegistrationAddress.Country'$v',
					[2]=d.NaturalPerson.RegistrationAddress.Region'$v',
					[4]=d.NaturalPerson.RegistrationAddress.Location'$v',
				--	[1]=d.NaturalPerson.RegistrationAddress.LocationType'$v',
					[3]=d.NaturalPerson.RegistrationAddress.District'$v',
					[5]=d.NaturalPerson.RegistrationAddress.Street'$v',
					[6]=d.NaturalPerson.RegistrationAddress.HouseNumber'$v',
					[13]=d.NaturalPerson.RegistrationAddress.Building'$v',
					[7]=d.NaturalPerson.RegistrationAddress.Block'$v',
					[8]=d.NaturalPerson.RegistrationAddress.Apartment'$v',
					[21]=d.NaturalPerson.RegistrationAddress.Description'$v',
					[9]="1"
				}
			)
			recAdr.Base:AddLink (recAdr.SN, 300, "ФЛ", recSubject.SN) --связываем с реестром лицом
			recAdr.Base:AddLink (recAdr.SN, 310, "РЕ", rec.SN) --связываем с реестром XML

			-- модернизация/добовление адреса проживания
			local recAdr=findAdr(recSetAdr,"2",d.NaturalPerson.LivingAddress.Region'$v',d.NaturalPerson.LivingAddress.Location'$v',d.NaturalPerson.LivingAddress.HouseNumber'$v',d.NaturalPerson.LivingAddress.Description'$v') or addRecord(baseAD)
			local ok,err=addVal(recAdr,
				{
					[10]=d.NaturalPerson.LivingAddress.PostalCode'$v',
					[1]=d.NaturalPerson.LivingAddress.Country'$v',
					[2]=d.NaturalPerson.LivingAddress.Region'$v',
					[4]=d.NaturalPerson.LivingAddress.Location'$v',
				--	[1]=d.NaturalPerson.LivingAddress.LocationType'$v',
					[3]=d.NaturalPerson.LivingAddress.District'$v',
					[5]=d.NaturalPerson.LivingAddress.Street'$v',
					[6]=d.NaturalPerson.LivingAddress.HouseNumber'$v',
					[13]=d.NaturalPerson.LivingAddress.Building'$v',
					[7]=d.NaturalPerson.LivingAddress.Block'$v',
					[8]=d.NaturalPerson.LivingAddress.Apartment'$v',
					[21]=d.NaturalPerson.LivingAddress.Description'$v',
					[9]="2"
				}
			)
			recAdr.Base:AddLink (recAdr.SN, 300, "ФЛ", recSubject.SN) --связываем с реестром лицом
			recAdr.Base:AddLink (recAdr.SN, 310, "РЕ", rec.SN) --связываем с реестром XML


			--банкротство ФЛ
			if not ti(d.BankruptcyNP) then
				local r=addRecord(baseBF)
				local ok,err=addVal(rec,
					{
						[1]=d.BankruptcyNP.IDBankruptcy'$v',
						[2]=d.BankruptcyNP.TypeOfBankruptcyProcedure'$v',
						[3]=d.BankruptcyNP.DateOfInclusion'$v',
						[4]=d.BankruptcyNP.LinkOfInclusion'$v',
						[5]=d.BankruptcyNP.AdditionalInformation'$v',
						[6]=d.BankruptcyNP.OtherAdditionalInformation '$v',
						[7]=d.BankruptcyNP.FinancialManagerPowersStartDate'$v',
						[8]=d.BankruptcyNP.FinancialManagerPowersEndDate'$v',
					}
				)
				if not ok then error{errText=err, errType=10} end
				r.Base:AddLink (r.SN, 300, "ФЛ", recSubject.SN) --связываем с реестром лицом
				r.Base:AddLink (r.SN, 310, "РЕ", rec.SN) --связываем с реестром XML
			end
		end



		if not ti(d.LegalPerson) then -- у нас юрик
			recSubject=(do
				local recSetUL=baseUL:StringRequest("ОТ ЮЛ 7 РВ "..d.LegalPerson.OGRN'$v'.." И 8 РВ "..d.LegalPerson.INN'$v')
				if recSetUL.Count==0 then return nil end
				return recSetUL:GetRecordByIndex(1)
			end)() or addRecord(baseUL)

			local ok,err=addVal(recSubject,
				{
				[13]=d.LegalPerson.SubjectCode'$v',
				[1]=d.LegalPerson.FullName'$v',
				[5]=d.LegalPerson.ShortName'$v',
				[6]=d.LegalPerson.FirmName'$v',
				[57]=d.LegalPerson.EngName'$v',
				[7]=d.LegalPerson.OGRN'$v',
				[9]=d.LegalPerson.RegistrtionNumber'$v',
				[8]=d.LegalPerson.INN'$v',
				[55]=d.LegalPerson.ReorganizationFullName'$v',
				[56]=d.LegalPerson.ReorganizationShortName'$v',
				[58]=d.LegalPerson.ReorganizationFirmName'$v',
				[59]=d.LegalPerson.ReorganizationEngName'$v',
				[60]=d.LegalPerson.ReorganizationОGRN'$v',
				[63]=d.LegalPerson.ReorganizationRegistrtionNumber'$v',
				[61]=d.LegalPerson.ReorganizationINN'$v',
				[62]=d.LegalPerson.RegistrationAddressPhone'$v',
				[203]=PartnerID,
				[204]=DistributorID,
				}
			)
			if not ok then error{errText=err, errType=10} end
			recSubject.Base:AddLink (recSubject.SN, 353, "РЕ", rec.SN) -- связываем с реестром XML

			local recSetAdr=recSubject:GetValue(350,"АД")
			local recAdr=findAdr(recSetAdr,"3",d.LegalPerson.RegistrationAddress.Region'$v',d.LegalPerson.RegistrationAddress.Location'$v',d.LegalPerson.RegistrationAddress.HouseNumber'$v',d.LegalPerson.RegistrationAddress.Description'$v') or addRecord(baseAD)
			local ok,err=addVal(recAdr,
				{
					[10]=d.LegalPerson.RegistrationAddress.PostalCode'$v',
					[1]=d.LegalPerson.RegistrationAddress.Country'$v',
					[2]=d.LegalPerson.RegistrationAddress.Region'$v',
					[4]=d.LegalPerson.RegistrationAddress.Location'$v',
				--	[1]=d.LegalPerson.RegistrationAddress.LocationType'$v',
					[3]=d.LegalPerson.RegistrationAddress.District'$v',
					[5]=d.LegalPerson.RegistrationAddress.Street'$v',
					[6]=d.LegalPerson.RegistrationAddress.HouseNumber'$v',
					[13]=d.LegalPerson.RegistrationAddress.Building'$v',
					[7]=d.LegalPerson.RegistrationAddress.Block'$v',
					[8]=d.LegalPerson.RegistrationAddress.Apartment'$v',
					[21]=d.LegalPerson.RegistrationAddress.Description'$v',
					[9]="3"
				}
			)
			recAdr.Base:AddLink (recAdr.SN, 300, "ЮЛ", recSubject.SN) --связываем с реестром лицом
			recAdr.Base:AddLink (recAdr.SN, 310, "РЕ", rec.SN) --связываем с реестром XML
			table.insert(recCKKI,recAdr)

			if not ti(d.LegalPerson.FactAddress) then
				local recAdr=findAdr(recSetAdr,"4",d.LegalPerson.FactAddress.Region'$v',d.LegalPerson.FactAddress.Location'$v',d.LegalPerson.FactAddress.HouseNumber'$v',d.LegalPerson.FactAddress.Description'$v') or addRecord(baseAD)
				local ok,err=addVal(recAdr,
					{
						[10]=d.LegalPerson.FactAddress.PostalCode'$v',
						[1]=d.LegalPerson.FactAddress.Country'$v',
						[2]=d.LegalPerson.FactAddress.Region'$v',
						[4]=d.LegalPerson.FactAddress.Location'$v',
					--	[1]=d.LegalPerson.FactAddress.LocationType'$v',
						[3]=d.LegalPerson.FactAddress.District'$v',
						[5]=d.LegalPerson.FactAddress.Street'$v',
						[6]=d.LegalPerson.FactAddress.HouseNumber'$v',
						[13]=d.LegalPerson.FactAddress.Building'$v',
						[7]=d.LegalPerson.FactAddress.Block'$v',
						[8]=d.LegalPerson.FactAddress.Apartment'$v',
						[21]=d.LegalPerson.FactAddress.Description'$v',
						[9]="4"
					}
				)
				recAdr.Base:AddLink (recAdr.SN, 300, "ЮЛ", recSubject.SN) --связываем с реестром лицом
				recAdr.Base:AddLink (recAdr.SN, 310, "РЕ", rec.SN) --связываем с реестром XML
				table.insert(recCKKI,recAdr)
			end

			--банкротство ЮЛ
			if not ti(d.BankruptcyLP) then
				local r=addRecord(baseBK)
				local ok,err=addVal(r,
					{
						[1]=d.BankruptcyLP.IDBankruptcy'$v',
						[2]=d.BankruptcyLP.CourtName'$v',
						[3]=d.BankruptcyLP.ClaimNumber'$v',
						[4]=d.BankruptcyLP.DateConsideration'$v',
						[5]=d.BankruptcyLP.Status'$v',
						[6]=d.BankruptcyLP.Resolution '$v',
					}
				)
				if not ok then error{errText=err, errType=10} end
				r.Base:AddLink (r.SN, 300, "ЮЛ", recSubject.SN) --связываем с реестром лицом
				r.Base:AddLink (r.SN, 310, "РЕ", rec.SN) --связываем с реестром XML
			end
		end

		--- Обработка заявки
		if not ti(d.ApplicationInfo) then
			local r=(do
				local rs=recSubject:GetValue(300,"ЗВ")
				if rs.Count==0 then return nil end
				rs:StringRequest("ОТ ЗВ 2 РВ '"..d.ApplicationInfo.ApplicationNumber'$v'.."' И 3 РВ "..d.ApplicationInfo.ApplicationDate'$v')
				if rs.Count==0 then return nil end
				return rs:GetRecordByIndex(1)
			end)() or addRecord(baseZV)
			local ok,err = addVal(r,
				{
					[1]=d.ApplicationInfo.Region'$v',
					[2]=d.ApplicationInfo.ApplicationNumber'$v',
					[3]=d.ApplicationInfo.ApplicationDate'$v',
					[4]=not ti(d.ApplicationInfo.ResolutionYes) and d.ApplicationInfo.ResolutionYes.ApplicationDateClose'$v',
					[7]=d.ApplicationInfo.ApplicationType'$v',
					[8]=d.ApplicationInfo.ApplicationSum'$v',
					[10]=d.ApplicationInfo.ApplicationCurrency'$v',
					[11]=d.ApplicationInfo.ApplicationChannel'$v',
					[13]=d.ApplicationInfo.ResolutionDate'$v',
					[16]=not ti(d.ApplicationInfo.ResolutionNo) and d.ApplicationInfo.ResolutionNo.RejectType'$v',
					[17]=not ti(d.ApplicationInfo.ResolutionNo) and  d.ApplicationInfo.ResolutionNo.RejectText'$v',
					[18]=not ti(d.ApplicationInfo.ResolutionYes) and d.ApplicationInfo.ResolutionYes.CreditNumber'$v',
					[19]=not ti(d.ApplicationInfo.ResolutionYes) and d.ApplicationInfo.ResolutionYes.ApplicationSum'$v',
					[20]=not ti(d.ApplicationInfo.ResolutionYes) and d.ApplicationInfo.ResolutionYes.ApplicationCurrency'$v',
					[21]=not ti(d.ApplicationInfo.ResolutionYes) and d.ApplicationInfo.ResolutionYes.ApplicationType'$v',
					[203]=PartnerID,
					[204]=DistributorID,
				}
			)
			if not ok then error{errText=err, errType=10} end
			r.Base:AddLink (r.SN, 300, "ФЛ", recSubject.SN) --связываем с реестром лицом
			r.Base:AddLink (r.SN, 310, "РЕ", rec.SN) -- связываем с реестром XML
		end


		-- сохранение кредита
		if not ti(d.CreditInfo) then
			local recSetNCD=recSubject:GetValue(300,"NC")
			recSetNCD:StringRequest("ОТ NC 3 РВ '"..d.CreditInfo.CreditNumber'$v'.."' И 6 РВ "..d.CreditInfo.CreditDateOpened'$v'.." И 203 РВ "..PartnerID)
		--	MsgBox(recSetNCD.Count)
			local recNCD=(do
				if recSetNCD.Count==0 then return nil end
				local rNCD
				for r in recSetNCD.Records do
					if r:GetValue(740,"NC").Count==0 then rNCD=r break end
				end
				if not rNCD then return nil end

				-- проверка на наличие изменений в КД
				if (
					rNCD:GetValue(7)~=d.CreditInfo.CreditSum'$v' or
					rNCD:GetValue(8)~=d.CreditInfo.CreditDateFinal'$v' or
					rNCD:GetValue(9)~=d.CreditInfo.CreditInterestDateFinal'$v'
				)
				then
					local oldRecNCD=rNCD
					rNCD = addRecord(baseNC)
					rNCD.Base:AddLink (rNCD.SN, 760, "NC", oldRecNCD.SN) -- связываем с прошлыми условиями кредитования
				end


				return rNCD
			end)() or addRecord(baseNC)
			local set_value = {
				[99]=d.CreditInfo.ID'$v',
				[1]=d.CreditInfo.CreditType'$v',
				[2]=d.CreditInfo.CreditRegion'$v',
				[3]=d.CreditInfo.CreditNumber'$v',
				[4]=(do
					if d.AnotherOrganizationTypeOfCredit'$v'~="" then return d.AnotherOrganizationTypeOfCredit'$v' end
					if d.CreditorType'$v'=="1" then return "2" end
					if d.CreditorType'$v'=="2" then return "1" end
					if d.CreditorType'$v'=="3" then return "1" end
				end)(),
				[5]=d.CreditInfo.ApplicationNumber'$v',
				[6]=d.CreditInfo.CreditDateOpened'$v',
				[7]=d.CreditInfo.CreditSum'$v',
				[8]=d.CreditInfo.CreditDateFinal'$v',
				[9]=d.CreditInfo.CreditInterestDateFinal'$v',
				[10]=d.CreditInfo.CreditCurrency'$v',
				[11]=d.CreditInfo.CreditSummFull'$v',
				[12]="1", -- отметка об окрытие кредита, ниже идет перезапись в случае наличие информации о закрытии кредита

				--переход обязательств на поручителя
				[67]=d.CreditInfo.GuaranteeNumber'$v',
				[68]=d.CreditInfo.MainNumber'$v',
				[69]=(do
					if d.CreditInfo.Reason'$v'== "1" then return "Добровольно" end
					if d.CreditInfo.Reason'$v'== "2" then return "По решению суда" end
				end)(),


				[203]=PartnerID,
				[204]=DistributorID,
				}
			-- сохранение условий кредита
			if _G.JSON_OUT[IDD] then
				set_value[100] = _G.JSON_OUT[IDD].created
			end
			local recNCD,err = addVal(recNCD, set_value)
			if not recNCD then error{errText=err, errType=10} end


			-- сохраняем последнии данные о кредите, в случае ели дата платеж и дата актуальности бошльше
			local dPay = d.CreditInfo

			local basePayDate=(DateTime(recNCD:GetValue(16)).IsValid and recNCD:GetValue(16)) or "01.01.1900"
			local baseRelevanceDate=(DateTime(recNCD:GetValue(101)).IsValid and recNCD:GetValue(101)) or "01.01.1900"

			if DateTime(dPay.DateLastPayment'$v')>=DateTime(basePayDate) and DateTime(d.RelevanceDate'$v')>=DateTime(baseRelevanceDate)then


				local recNCD,err = addVal(recNCD,
				{
					[12]=(do -- ели нет блока о закрытии кредита, тогда считаем его открытым
						if not ti(dPay.CloseCredit) then return "3" end
						return "1"
					end)(),

					-- информация о закрытии кредита
					[13]=not ti(dPay.CloseCredit) and dPay.CloseCredit.CreditClosedDate'$v',
					[14]=(do
						if not ti(dPay.CloseCredit) then
							if dPay.CloseCredit.OtherCreditClosedReason'$v' == "1" then return "Субъект исполнил свои обязательства" end
							if dPay.CloseCredit.OtherCreditClosedReason'$v' == "2" then return "Погашен за счет обеспечения" end
							if dPay.CloseCredit.OtherCreditClosedReason'$v' == "3" then return "Переуступка прав требований" end
							return dPay.CloseCredit.OtherCreditClosedReason'$v'
						end
					end)(),

					[16]=dPay.DateLastPayment'$v',

					[23]=dPay.CurrentCreditSum'$v',
					[24]=dPay.CurrentCreditSumPerc'$v',
					[25]=dPay.OtherAmount'$v',
					[31]=dPay.CurrentCreditSumPast'$v',

					[27]=dPay.DelaySum'$v',
					[28]=dPay.DelaySumPerc'$v',
					[29]=dPay.OtherDelaySum'$v',
					[30]=dPay.DelaySumPast'$v',

					[26]=dPay.Balans'$v',
					[101]=d.RelevanceDate'$v',

				}
				)
			end
			if not recNCD then error{errText=err, errType=10} end

			--- переуступка прав
			if not ti(d.CreditInfo.RightOfClaim) then
				local bROC,err = addVal(recNCD,
					{
					[49]=d.CreditInfo.RightOfClaim.Date'$v',
					--фл
					[51]=not ti(d.CreditInfo.RightOfClaim.NaturalPerson) and d.CreditInfo.RightOfClaim.NaturalPerson.Surname'$v',
					[52]=not ti(d.CreditInfo.RightOfClaim.NaturalPerson) and d.CreditInfo.RightOfClaim.NaturalPerson.FirstName'$v',
					[53]=not ti(d.CreditInfo.RightOfClaim.NaturalPerson) and d.CreditInfo.RightOfClaim.NaturalPerson.PatronymicName'$v',
					[54]=not ti(d.CreditInfo.RightOfClaim.NaturalPerson) and d.CreditInfo.RightOfClaim.NaturalPerson.DateOfBirth'$v',
					[55]=not ti(d.CreditInfo.RightOfClaim.NaturalPerson) and d.CreditInfo.RightOfClaim.NaturalPerson.PlaceOfBirth'$v',
					[56]=not ti(d.CreditInfo.RightOfClaim.NaturalPerson) and d.CreditInfo.RightOfClaim.NaturalPerson.SeriesAndNumber'$v',
					[57]=not ti(d.CreditInfo.RightOfClaim.NaturalPerson) and d.CreditInfo.RightOfClaim.NaturalPerson.IssueDate'$v',
					[58]=not ti(d.CreditInfo.RightOfClaim.NaturalPerson) and d.CreditInfo.RightOfClaim.NaturalPerson.IssueAuthority'$v',
					[59]=not ti(d.CreditInfo.RightOfClaim.NaturalPerson) and d.CreditInfo.RightOfClaim.NaturalPerson.INN'$v',
					[15]=not ti(d.CreditInfo.RightOfClaim.NaturalPerson) and d.CreditInfo.RightOfClaim.NaturalPerson.Insurance'$v',
					--юл
					[61]=not ti(d.CreditInfo.RightOfClaim.LegalPerson) and d.CreditInfo.RightOfClaim.LegalPerson.FullName'$v',
					[62]=not ti(d.CreditInfo.RightOfClaim.LegalPerson) and d.CreditInfo.RightOfClaim.LegalPerson.ShortName'$v',
					[64]=not ti(d.CreditInfo.RightOfClaim.LegalPerson) and d.CreditInfo.RightOfClaim.LegalPerson.OGRN'$v',
					[63]=not ti(d.CreditInfo.RightOfClaim.LegalPerson) and d.CreditInfo.RightOfClaim.LegalPerson.RegistrtionNumber'$v',
					[65]=not ti(d.CreditInfo.RightOfClaim.LegalPerson) and d.CreditInfo.RightOfClaim.LegalPerson.INN'$v',
					}
				)
				if not bROC then error{errText="Ошибка в разборе блока переуступка прав: "..err, errType=10} end
			end
			--линки
			recNCD.Base:AddLink (recNCD.SN, 300, recSubject.Base.Code, recSubject.SN) --связываем с лицом
			recNCD.Base:AddLink (recNCD.SN, 310, "РЕ", rec.SN) -- связываем с реестром XML

			--Сохранение в архивную базу
			local recSetArch=recNCD:GetValue(410,"AR")
			local racAr=(do
				if recSetArch.Count==0 then return nil end
				for r in recSetArch.Records do
					if r:GetValue(16)==dPay.DateLastPayment'$v' and r:GetValue(31)==dPay.CurrentCreditSumPast'$v' and r:GetValue(30)==dPay.DelaySumPast'$v' then
						return r
					end
				end
				return nil
			end)() or addRecord(baseAR)

			local racAr,err = addVal(racAr,
				{
					[16]=dPay.DateLastPayment'$v',

					[23]=dPay.CurrentCreditSum'$v',
					[24]=dPay.CurrentCreditSumPerc'$v',
					[25]=dPay.OtherAmount'$v',
					[31]=dPay.CurrentCreditSumPast'$v',

					[27]=dPay.DelaySum'$v',
					[28]=dPay.DelaySumPerc'$v',
					[29]=dPay.OtherDelaySum'$v',
					[30]=dPay.DelaySumPast'$v',

					[26]=dPay.Balans'$v',
					[101]=d.RelevanceDate'$v'

				}
			)
			if not racAr then error{errText=err, errType=10} end
			racAr.Base:AddLink (racAr.SN, 400, "NC", recNCD.SN) --связываем с реестром лицом
			racAr.Base:AddLink (racAr.SN, 310, "РЕ", rec.SN) -- связываем с реестром XML

			-- платеж
			if not ti(d.CreditInfo.Payments) then
				local recSetPay=recNCD:GetValue(400,"PL")
				for i=1,d.CreditInfo.Payments.Payment'$n' do
					local dPay=d.CreditInfo.Payments.Payment[i]
					local recPay=(do
						if recSetPay.Count==0 then return nil end
						for r in recSetPay.Records do
							if r:GetValue(5)==dPay.DatePayment'$v' and r:GetValue(6)==dPay.SumPayment'$v' then
								return r
							end
						end
						return nil
					end)() or addRecord(basePL)
					local ok,err = addVal(recPay,
						{
						[5]=dPay.DatePayment'$v',
						[6]=dPay.SumPayment'$v',
						[12]=dPay.SumPayment30'$v',
						[13]=(do
							if dPay.PaymentVolume'$v'=="F" then return "Полностью" end
							if dPay.PaymentVolume'$v'=="P" then return "Не полностью" end
						end)(),

						--[=[[10]=d.CreditInfo.Balans'$v',

						[9]=d.CreditInfo.CurrentCreditSum'$v',
						[18]=d.CreditInfo.CurrentCreditSumPerc'$v',
						[19]=d.CreditInfo.OtherAmount'$v',



						[14]=dPay.PaymentAmountExcept12m'$v',
						[15]=dPay.PaymentCountExcept12m'$v',
						[16]=dPay.PaymentAmountExcept24m'$v',
						[17]=dPay.PaymentCountExcept24m'$v',

						[20]=d.CreditInfo.DelaySum'$v',
						[21]=d.CreditInfo.DelaySumPerc'$v',
						[22]=d.CreditInfo.OtherDelaySum'$v',

						[23]=d.CreditInfo.DelaySumPast'$v',--]=]
						[101]=d.RelevanceDate'$v'
						}
					)
					if not ok then error{errText=err, errType=10} end
					--линки
					recPay.Base:AddLink (recPay.SN, 500, "NC", recNCD.SN) --связываем с реестром лицом
					recPay.Base:AddLink (recPay.SN, 310, "РЕ", rec.SN) -- связываем с реестром XML
				end
			end

			-- залог(обеспечение)
			if not ti(d.CreditInfo.Ensure) then
				local rs=recNCD:GetValue(600,"EN")
				for i=1,d.CreditInfo.Ensure'$n' do
					local dEns=d.CreditInfo.Ensure'$n'[i]

					local recEnsure=(do
						if rs.Count==0 then return nil end
						for r in rs.Records do
							if (r:GetValue(1)):upper()==(dEns.IDEnsure'$v'):upper() and r:GetValue(7)==dEns.CollateralDate'$v' and r:GetValue(4)==dEns.CollateralValue'$v' then return r end
						end
						return nil
					end)() or addRecord(baseEN)

					local recEnsure,err = addVal(recEnsure,
						{
							[1]=(dEns.IDEnsure'$v'):upper(),
							[2]=dEns.Ensure'$v',
							[3]=dEns.EnsureDescription'$v',
							[4]=dEns.CollateralValue'$v',
							[5]=dEns.Currency'$v',
							[6]=dEns.CollateralDate'$v',
							[7]=dEns.EnsureDateStart'$v',
							[8]=dEns.EnsureDateEnd'$v',
						}
					)
					if not recEnsure then error{errText=err, errType=10} end
					recEnsure.Base:AddLink (recEnsure.SN, 500, recEnsure.Base.Code, recNCD.SN) -- связываем с кредитом
					recEnsure.Base:AddLink (recEnsure.SN, 310, "РЕ", rec.SN) -- связываем с реестром XML
				end
			end
		end


		-- Судебные разбирательства СР
		if not table.isempty(d.Claim) then
			local recSetClaim=recSubject:GetValue(362,"СР")
			for i=1,d.Claim'$n' do
				local dCleim=d.Claim[i]
				local recClaim=(do
					if recSetClaim.Count == 0 then return nil end
					for r in recSetPay.Records do
						if (r:GetValue(1)):upper()==(dCleim.ClaimNumber'$v'):upper() and r:GetValue(3)==dCleim.DateConsideration'$v' then return r end
					end
					return nil
				end)() or addRecord(baseCP)

				local ok,err = addVal(recClaim,
					{
						[1]=dCleim.ClaimNumber'$v',
						[2]=dCleim.CourtName'$v',
						[3]=dCleim.DateConsideration'$v',
						[4]=dCleim.ClaimDate'$v',
						[5]=dCleim.Plaintiff'$v',
						[6]=dCleim.Resolution'$v'
					}
				)
				if not ok then error{errText=err, errType=10} end
				recClaim.Base:AddLink (recClaim.SN, 300, recSubject.Base.Code, recSubject.SN) --связываем с кредитом
				recClaim.Base:AddLink (recClaim.SN, 310, "РЕ", rec.SN) -- связываем с реестром XML
			end
		end

		-- работа с гарантиями
		if not ti(d.BankGuaranty) then
			local recSetBG=recSubject:GetValue(300,"BG")
			recSetBG = baseBG:StringRreuest("ОТ BG01 2 РВ '"..d.BankGuaranty.GuarantyNumber'$v'.."'")
			local recBG=(do
				if recSetBG.Count==0 then return nil end
				for r in recSetBG.Records do
					if r:GetValue(3)~=d.BankGuaranty.GuarantySum'$v' then continue end
					if r:GetValue(5)~=d.BankGuaranty.GuarantyDateStart'$v' then continue end
					if r:GetValue(6)~=d.BankGuaranty.GuarantyDateClosed'$v' then continue  end
					return r
				end
				return nil
			end)() or addRecord(baseCP)

			local recBG,err = addVal(recBG,
				{
					[1]=d.BankGuaranty.Volume'$v',
					[2]=d.BankGuaranty.GuarantyNumber'$v',
					[3]=d.BankGuaranty.GuarantySum'$v',
					[4]=d.BankGuaranty.GuarantyCurrency'$v',
					[5]=d.BankGuaranty.GuarantyDateStart'$v',
					[6]=d.BankGuaranty.GuarantyDateClosed'$v',
					[7]=d.BankGuaranty.Date'$v',
					[8]=d.BankGuaranty.Reason'$v',
					[203]=PartnerID,
					[204]=DistributorID,
				}
			)
			if not recBG then error{errText=err, errType=10} end
			recBG.Base:AddLink (recBG.SN, 300, "ЮЛ", recSubject.SN) --связываем с лицом
			recBG.Base:AddLink (recBG.SN, 310, "РЕ", rec.SN) -- связываем с реестром XML
		end


		-- поручительство
		if not ti(d.GuaranteeInfo) then
			local recSet=recSubject:GetValue(300,"ПР")
			local recGI=(do
				for r in recSet.Records do
					if (r:GetValue(2)):upper()==(d.GuaranteeInfo.GuaranteeNumber'$v'):upper() and
					r:GetValue(5)==d.GuaranteeInfo.GuaranteeDateStart'$v' and
					r:GetValue(6)==d.GuaranteeInfo.GuaranteeDateClosed'$v' then
						return r
					end
				end
				return nil
			end)() or addRecord(baseGI)
			local recGI,err = addVal(recGI,
				{
				[1]=d.GuaranteeInfo.Volume'$v' ,
				[2]=d.GuaranteeInfo.GuaranteeNumber'$v' ,
				[3]=d.GuaranteeInfo.GuaranteeSum'$v' ,
				[4]=d.GuaranteeInfo.GuaranteeCurrency'$v' ,
				[5]=d.GuaranteeInfo.GuaranteeDateStart'$v' ,
				[6]=d.GuaranteeInfo.GuaranteeDateClosed'$v' ,
				[7]=d.GuaranteeInfo.CreditBorrowerNumber'$v' ,
				[8]=d.GuaranteeInfo.VolumeInPercent'$v' ,
				[203]=PartnerID,
				[204]=DistributorID,
				}
			)
			if not recGI then error{errText=err, errType=10} end
			recGI.Base:AddLink (recGI.SN, 300, recSubject.Base.Code, recSubject.SN) --связываем с лицом
			recGI.Base:AddLink (recGI.SN, 310, "РЕ", rec.SN) -- связываем с реестром XML
		end
	end)


	if not ok then -- удаляем созданные записи.
		--log("start del records "..render(tNewRec).." "..render(res))
		delRercord(tNewRec)
		--log"end del records"
	else -- если все хорошо
	--	log"DO_CKKI_START"
		for _,r in ipairs(recCKKI) do
			local ok,res = pcall(ckkiScript.run,r)			-- вызов ЦККИ
			if not ok or not res then
				MsgBox("СРОЧНО. Ошибка вызова ЦККИ: "..render{ok,res}.." "..r.Base.Code.." "..r.Base.Name.." "..r.SN)
				MsgBox(render{ckkiScript})
			--	MsgBox(render(tNewRec))
				delRercord(tNewRec)
				return nil,{errText="Системная ошибка взаимодействия с ЦККИ. Необходимо повоторить выгрузку информационного сообщения."}
			end
		end
	--	log"DO_CKKI_END"
		--ставим отметку, что все ок
		rec=rec.Base:GetRecord(rec.SN)
		rec:SetValue(5,1)
	--	log"SAVE_REC_START"
		rec:Update()
		--log"SAVE_REC_EN"
		local a=log and log"ОТРАБОТАЛИ"
	end
	if not ok then
	--	MsgBox(render{ok,res})
	end
	return ok,res
end
