require 'json'

local customBankCashe = require('sys.customBankCashe');
local bankName = [[SKB]];
local bankCKKI = customBankCashe.at_Bank(bankName);
local baseFL = bankCKKI:GetBase('ФЛ');
local baseUL = bankCKKI:GetBase('ЮЛ');

local Logfile = [[E:/json_script_out/UUID_FIX.log]];
local IJson_file = [[E:/json_script_out/skb.credithistories1.json]];
local errfile = [[E:/json_script_out/UUID_errors.log]];
local fixfile = [[E:/json_script_out/UUID_errorsfixfile.log]];
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

function credit_update(record, loan_num, loan_sum, loan_date, login, uuid)

	local BLOCK_NC = record:GetValue(300,'NC');

	if (BLOCK_NC.Count>0) then

		for doc in BLOCK_NC.Records do

			local source = doc:GetValue(203);
			source = source:swap('PRT040815',''):swap('PRT040814','');
			local source1 = (source == login) and true or false;
			local sum = tostring(doc:GetValue(7));
			local sum1 = (sum == tostring(loan_sum)) and true or false;
			local num = tostring(doc:GetValue(3));
			local num1 = (num == loan_num) and true or false;
			local date = tostring(doc:GetValue(6));
			local date1 = (date == loan_date) and true or false;

			log('try to write//'..source..'|'..login..'//'..sum..'|'..loan_sum..'//'..num..'|'..loan_num..'//'..date..'|'..loan_date..'//uuid|'..uuid);

			if (source1) and (sum1) and (num1) and (date1) then

				log('Ywrite//'..source..'|'..login..'//'..sum..'|'..loan_sum..'//'..num..'|'..loan_num..'//'..date..'|'..loan_date..'//uuid|'..uuid);

				local ok = record:Lock();
				if ok then -- если блокировка успешна, переходим к редактированию записи?

					record:SetValue(99, uuid);
					record:Update(); -- сохраняем запись
					record:Unlock(); -- разблокируем запись

				end;

			end;

		end;

	end;

end;

function recordset_worker(str_to_find, recordset, line, loan_num, loan_sum, loan_date, login, uuid);


	if recordset.Count == 0 then	log('Субъекта не нашлось//'..str_to_find..'//mongo_id//'..line['_id']['$oid']);	return 1; end;
	if recordset.Count > 1 then	log('Субъекта много//'..str_to_find..'//mongo_id//'..line['_id']['$oid']); 	return 1; end;

	for recPerson in recordset.Records do


		log('Работаю с //'..str_to_find..'//mongo_id//'..line['_id']['$oid']);
		credit_update(recPerson, loan_num, loan_sum, loan_date, login, uuid);

	end;

	return 0;

end;

function line_worker(line)

	if (line ~= '[') and (line ~= ']') then

		line = line:decode('utf-8');
		line = string.sub(line, 1, #line -1);
		line = json.decode(line);
		local login = string.upper(line['userName']);

		if (line['loan']) then

			local loan_num = line['loan']['num'];
			local loan_sum = line['loan']['sum'];
			local loan_date = date_transform(line['loan']['date']['$date']);

			if line['borrower']['fl'] then

				local fname = string.upper(line['borrower']['fl']['firstName']);
				local sname = string.upper(line['borrower']['fl']['lastName']);
				local db = date_transform(line['borrower']['fl']['dateOfBirth']['$date']);

				if (line['loan']['uuid']) and (line['loan']['uuid'] ~= '') then

					local uuid = line['loan']['uuid'];
					local str_to_find = [[ОТ ФЛ01 1 РВ ']]..sname..[[' И 2 РВ ']]..fname..[[' И 4 РВ ']]..db..[[']];
					local recSetPerson = baseFL:StringRequest(str_to_find);
					recordset_worker(str_to_find, recSetPerson, line, loan_num, loan_sum, loan_date, login, uuid);

				end;

			end;

			if line['borrower']['ul'] then

				local inn = line['borrower']['ul']['INN'];
				local ogrn = line['borrower']['ul']['OGRN'];

				if (line['loan']['uuid']) and (line['loan']['uuid'] ~= '') then

					local uuid = line['loan']['uuid'];

					if (inn ~= '') then

						local str_to_find = [[ОТ ЮЛ01 8 РВ ']]..inn..[[']];
						local recSetPerson = baseUL:StringRequest(str_to_find);
						recordset_worker(str_to_find, recSetPerson, line, loan_num, loan_sum, loan_date, login, uuid);

					end;

					if (ogrn ~= '') then

						local str_to_find = [[ОТ ЮЛ01 7 РВ ']]..ogrn..[[']];
						local recSetPerson = baseUL:StringRequest(str_to_find);
						recordset_worker(str_to_find, recSetPerson, line, loan_num, loan_sum, loan_date, login, uuid);

					end;

				end;

			end;

		end;

	end;

end;

function main(file)

	for line in io.lines(file) do

		local ok, err = pcall(line_worker, line);

		if (not ok) then err_log('ERROR//'..err..'//LINE//'..line) end;

	end;

end;

main(IJson_file)
