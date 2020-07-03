local baseÐÅ=GetBank():GetBase('ÐÅ');
local baseIS=GetBank():GetBase('ÈÑ');
local dir = [[E:/json_script_out/validate/]];
local fileName = [[match]];
local fileName_match_of_many10k = [[_of_many10k]];
local fileName_match_of_many5k_last12 = [[_of_many5k_last12]];
local fileType = [[.csv]];
local startDate = {};

startDate[1] = [[01.07.2020]];
startDate[2] = [[01.06.2020]];
startDate[3] = [[01.05.2020]];
startDate[4] = [[01.04.2020]];
startDate[5] = [[01.03.2020]];
startDate[6] = [[01.02.2020]];
startDate[7] = [[01.01.2020]];
startDate[8] = [[01.12.2019]];
startDate[9] = [[01.11.2019]];
startDate[10] = [[01.10.2019]];
startDate[11] = [[01.09.2019]];
startDate[12] = [[01.08.2019]];
startDate[13] = [[01.07.2019]];

function log_files(m)

	---ïðèìèòèâíûé ëîããåð, òóïî ïèøåò îøèáêè â ôàéë---
	local ok,err =	appendfile(fileName,m..'\r\n');
	if not ok then MsgBox(render{err,fileName}) error'Îøèáêà ëîããèðîâàíèÿ' end;

end;
--ÎÒ ÐÅ01 11 ÐÂ SASD È 1 ÐÂ 09.07.2020
function prelog(m)

return tostring(m)..';';

end;

function button1_Click( control, event )

	fileName =fileName..fileName_match_of_many10k..fileType;
	log_files('login;name;ogrn;count;')
	local clients = baseIS:GetRecordSet();

		for client in clients.Records do

			-- local answer = "";
			local login = client:GetValue(3);
			local name = client:GetValue(4);
			local ogrn = client:GetValue(6);
			-- answer +=login
			-- local str_to_find = [[ÎÒ ÔË01 1 ÐÂ ']]..SURNAME..[[' È 2 ÐÂ ']]..NAME..[[' È 4 ÐÂ ']]..DateOfB..[[']];
			local str_to_find = [[ÎÒ ÐÅ01 11 ÐÂ ']]..login..[[']];
			--ÎÒ ÐÅ01 11 ÐÂ SASD È 1 ÐÂ 09.07.2020
			local recSetClient = baseÐÅ:StringRequest(str_to_find);
			if ((recSetClient.Count	== 10000) or (recSetClient.Count > 100000)) then log_files(prelog(login)..prelog(name)..prelog(ogrn)..prelog(recSetClient.Count)); end;

		end;

	MsgBox('END')

end;

function button2_Click( control, event )

	fileName =fileName..fileName_match_of_many10k..fileType;
	log_files('login;name;ogrn;countAll;count1(06/2020);count2(05/2020);count3(04/2020);count4(03/2020);count5(02/2020);count6(01/2020);count7(12/2019);count8(11/2019);count9(10/2019);count10(09/2019);count11(08/2019);count12(07/2019);')
	local clients = baseIS:GetRecordSet();

		for client in clients.Records do

			-- local answer = "";
			local login = client:GetValue(3);
			local name = client:GetValue(4);
			local ogrn = client:GetValue(6);
			-- answer +=login
			-- local str_to_find = [[ÎÒ ÔË01 1 ÐÂ ']]..SURNAME..[[' È 2 ÐÂ ']]..NAME..[[' È 4 ÐÂ ']]..DateOfB..[[']];
			local str_to_find = [[ÎÒ ÐÅ01 11 ÐÂ ']]..login
			local recSetClient = baseÐÅ:StringRequest(str_to_find);
			local count = recSetClient.Count;
			local cont_many = "";

			for i = 1, 12, 1 do


				--ÎÒ ÐÅ01 1 ÂÈ 01.06.2020 01.07.2020 È 11 ÐÂ DDD
				local str_to_find = [[ÎÒ ÐÅ01 11 ÐÂ ']]..login..[[' È 1 ÂÈ ']]..startDate[i+1]..[[' ']]..startDate[i]..[[']];
				local recSetClient = baseÐÅ:StringRequest(str_to_find);
				if ((recSetClient.Count == 5000) or (recSetClient.Count > 5000)) then count_many = count_many + prelog(recSetClient.Count); end;

			end;

			if not cont_many == "" then log_files(prelog(login)..prelog(name)..prelog(ogrn)..prelog(count)..cont_many); end;

		end;

	MsgBox('END')

end;
