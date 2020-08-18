require 'json'

local customBankCashe = require('sys.customBankCashe');
local bankName = [[SKB]];
local bankCKKI = customBankCashe.at_Bank(bankName);

local Logfile = [[E:/json_script_out/MagazinLog.log]];
-- local IJson_file = [[E:/json_script_out/skb.credithistories1.json]];
local strateg = [[E:/json_script_out/Magazin.csv]];
local errfile = [[E:/json_script_out/MagazinErr.log]];
local fixfile = [[E:/json_script_out/MagazinFix.log]];

local baseRE = bankCKKI:GetBase('РЕ');

function Line_From(file)

	if not IO.File.Exists(file or "") then return {} end;

	local tS = {};
	local f=io.input(file);

	for line in f:lines() do

		line = line:decode('utf-8')
		table.insert(tS,line);

	end;

	f:close ();
	return tS;

end;

function fcount(m)

	---примитивный логгер, тупо пишет ошибки в файл---
	m = tostring(m)
	local ok,err =	appendfile(fcounter,m..'\r\n');
	if not ok then MsgBox(render{err,Logfile}) error'Ошибка логгирования' end;

end;

function fix_log(m)

	---примитивный логгер, тупо пишет ошибки в файл---
	m = tostring(m)
	local ok,err =	appendfile(fixfile,m..'\r\n');
	if not ok then MsgBox(render{err,Logfile}) error'Ошибка логгирования' end;

end;

function log(m)

	---примитивный логгер, тупо пишет ошибки в файл---
	m = tostring(m)
	local ok,err =	appendfile(Logfile,m..'\r\n');
	if not ok then MsgBox(render{err,Logfile}) error'Ошибка логгирования' end;

end;

function err_log(m)

	---примитивный логгер, тупо пишет ошибки в файл---
	m = tostring(m)
	local ok,err =	appendfile(errfile,m..'\r\n');
	if not ok then MsgBox(render{err,Logfile}) error'Ошибка логгирования' end;

end;

function date_app(d,m,y)

	table_of_years = {
		['2020'] = 12,
		['2016'] = 12,
		['2012'] = 12,
		['2008'] = 12,
		['2004'] = 12,
		['2000'] = 12,
		['1996'] = 12,
		['1992'] = 12,
		['1988'] = 12,
		['1984'] = 12,
		['1980'] = 12,
		['1976'] = 12,
		['1972'] = 12,
		['1968'] = 12,
		['1964'] = 12,
		['1960'] = 12,
		['1956'] = 12,
		['1952'] = 12,
		['1948'] = 12,
		['1944'] = 12,
		['1940'] = 12,
		['1936'] = 12,
		['1932'] = 12,
		['1928'] = 12,
		['1924'] = 12,
		['1920'] = 12,
		['1916'] = 12,
		['1912'] = 12,
		['1908'] = 12,
		['1904'] = 12,
	};

	table_of_month = {

		['01'] = 31,
		['02'] = 28,
		['03'] = 31,
		['04'] = 30,
		['05'] = 31,
		['06'] = 30,
		['07'] = 31,
		['08'] = 31,
		['09'] = 30,
		['10'] = 31,
		['11'] = 30,
		['12'] = 31,
	};


	local day = tonumber(d);
	local mon = tonumber(m);
	local year = tonumber(y);

	day = day + 1;

	if (day > 28) then

		if (day > table_of_month[m]) then

			if (m ~= '02') then

				day = '01';

				if (mon == 12) then

					mon = '01';
					year = year + 1;

				else

					mon = mon + 1;

				end;

			else

				if (table_of_years[y] ~= 12) then

					day = '01';
					mon = '03';

				end;

			end;

		end;

	end;

	day = tostring(day);
	mon = tostring(mon);
	mon = (#mon<2) and ('0'..mon) or (mon);
	day = (#day<2) and ('0'..day) or (day);

	return tostring(day)..'.'..tostring(mon)..'.'..tostring(year);

end;

function date_transform(date)

	--fix_log(date)
	date = string.sub(date, 1, 10);
	dt = {};
	date = date:swap('-','.');
	date = string.split(date,'.');
	local answer =  date_app(date[3], date[2], date[1]);

	--fix_log(answer);

	return answer;

end;

function credit_update(record, new_date)

	local BLOCK_NC = record:GetValue(12,'NC');

	if (BLOCK_NC.Count>0) then

		for doc in BLOCK_NC.Records do

			log('execute to write//'..doc.SN..'//100_date||101_date//'..doc:GetValue(100)..'||'..doc:GetValue(101)..'//newdate//'..new_date);
			fix_log('fixed ||'..doc:GetValue(3)..';'..doc:GetValue(6)..';'..doc:GetValue(7))

				local ok = doc:Lock();
				if ok then -- если блокировка успешна, переходим к редактированию записи?

					doc:SetValue(101, new_date);
					doc:SetValue(100, new_date);
					doc:Update(); -- сохраняем запись
					doc:Unlock(); -- разблокируем запись

				end;
		end;

	end;

end;


function recordset_worker(str_to_find, recordset, new_date)


	if recordset.Count == 0 then log('Субъекта не нашлось//'..str_to_find);	return 1; end;
	-- if recordset.Count > 1 then	log('Субъекта много//'..str_to_find); 	return 1; end;

	for recPerson in recordset.Records do

		-- log('Работаю с //'..str_to_find..'//mongo_id//'..line['_id']['$oid']);
		credit_update(recPerson, new_date)

	end;

	return 0;

end;

function line_worker(splited)

	local login = string.upper(splited[1]);
	local packID = splited[2];
	local new_date = splited[3];
	packID = [[CH#PRT040815#]]..packID..[[PREFIXSTSENDPACKCHNEW]];
	-- CH#PRT040815#5dc93e9ed5401f18d8d650fePREFIXSTSENDPACKCHNEW
	local str_to_find = [[ОТ РЕ01 11 РВ  ']]..login..[[' И 3 РВ ']]..packID..[[']];
	local recSetPerson = baseRE:StringRequest(str_to_find);
	recordset_worker(str_to_find, recSetPerson, new_date)

end;

function start_work(currentFile)

	local UniTable = Line_From(currentFile);
	log("start work with||"..currentFile)
	if #UniTable>0 then

		for line in ipairs(UniTable) do

			local splited = UniTable[line]:split(";")
			local ok, err = pcall(line_worker, splited);
			if (not ok) then err_log('ERROR//'..err..'//LINE//'..line) end;

		end;

	end;

end;

local currentFile = ThisAction.FullFileName;
start_work(currentFile);
