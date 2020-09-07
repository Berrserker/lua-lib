require 'json'

local customBankCashe = require('sys.customBankCashe');
local bankName = [[SKB]];
local bankCKKI = customBankCashe.at_Bank(bankName);
local baseFL = bankCKKI:GetBase('��');
local baseUL = bankCKKI:GetBase('��');
local baseNC = bankCKKI:GetBase("NC");

local Logfile = [[E:/json_script_out/UUID_FIX.log]];
-- local IJson_file = [[E:/json_script_out/skb.credithistories1.json]];
local strateg = [[E:/json_script_out/skbfile.csv]];
local errfile = [[E:/json_script_out/UUID_errors.log]];
local fixfile = [[E:/json_script_out/UUID_errorsfixfile.log]];

function str_log(m)

	---����������� ������, ���� ����� ������ � ����---
	m = tostring(m);
	local ok,err =	appendfile(strateg,m..'\r\n');
	if not ok then MsgBox(render{err,Logfile}) error'������ ������������' end;

end;

function log(m)

	---����������� ������, ���� ����� ������ � ����---
	m = tostring(m);
	local ok,err =	appendfile(Logfile,m..'\r\n');
	if not ok then MsgBox(render{err,Logfile}) error'������ ������������' end;

end;

function err_log(m)

	---����������� ������, ���� ����� ������ � ����---
	m = tostring(m);
	local ok,err =	appendfile(errfile,m..'\r\n');
	if not ok then MsgBox(render{err,Logfile}) error'������ ������������' end;

end;

function recordset_worker(record)

	local str_out = '';
	local source = record:GetValue(203);
	source = source:swap('PRT040815',''):swap('PRT040814','');
	local sn = record.SN;
	local reestr = record:GetValue(310,'��');
	local strPack = '';
	local strXML = '';


	for rw in reestr.Records do

		strPack = rw:GetValue(3);
		strXML = rw:GetValue(8);
		break;

	end;

	str_out = source..';'..sn..';'..strPack..';'..strXML;
	str_log(str_out)

	return 0;

end;

function main()

	-- local str_to_find = [[�� ��01 1 �� ']]..sname..[[' � 2 �� ']]..fname..[[' � 4 �� ']]..db..[[']];
	local str_to_find = [[�� NC01 6 �� 29.10.2019 � 99 ��]];
	local recordset = baseNC:StringRequest(str_to_find);
	if recordset.Count == 0 then log('������� �� �������//'..str_to_find); return 1; end;

	for recPerson in recordset.Records do

		local ok, err = pcall(recordset_worker, recPerson);

		if (not ok) then err_log('ERROR//'..err) end;

	end;

	return 0;

end;

main()
