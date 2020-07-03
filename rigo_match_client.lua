local base��=GetBank():GetBase('��');
local baseIS=GetBank():GetBase('��');
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

	---����������� ������, ���� ����� ������ � ����---
	local ok,err =	appendfile(fileName,m..'\r\n');
	if not ok then MsgBox(render{err,fileName}) error'������ ������������' end;

end;
--�� ��01 11 �� SASD � 1 �� 09.07.2020
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
			-- local str_to_find = [[�� ��01 1 �� ']]..SURNAME..[[' � 2 �� ']]..NAME..[[' � 4 �� ']]..DateOfB..[[']];
			local str_to_find = [[�� ��01 11 �� ']]..login..[[']];
			--�� ��01 11 �� SASD � 1 �� 09.07.2020
			local recSetClient = base��:StringRequest(str_to_find);
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
			-- local str_to_find = [[�� ��01 1 �� ']]..SURNAME..[[' � 2 �� ']]..NAME..[[' � 4 �� ']]..DateOfB..[[']];
			local str_to_find = [[�� ��01 11 �� ']]..login
			local recSetClient = base��:StringRequest(str_to_find);
			local count = recSetClient.Count;
			local cont_many = "";

			for i = 1, 12, 1 do


				--�� ��01 1 �� 01.06.2020 01.07.2020 � 11 �� DDD
				local str_to_find = [[�� ��01 11 �� ']]..login..[[' � 1 �� ']]..startDate[i+1]..[[' ']]..startDate[i]..[[']];
				local recSetClient = base��:StringRequest(str_to_find);
				if ((recSetClient.Count == 5000) or (recSetClient.Count > 5000)) then count_many = count_many + prelog(recSetClient.Count); end;

			end;

			if not cont_many == "" then log_files(prelog(login)..prelog(name)..prelog(ogrn)..prelog(count)..cont_many); end;

		end;

	MsgBox('END')

end;
