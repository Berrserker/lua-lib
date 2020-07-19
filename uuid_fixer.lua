require 'json'

local customBankCashe = require('sys.customBankCashe');
local bankName = [[SKB]];
local bankCKKI = customBankCashe.at_Bank(bankName);
local baseFL = bankCKKI:GetBase('ФЛ');
local baseUL = bankCKKI:GetBase('ЮЛ');

local Logfile = [[E:/json_script_out/UUID_FIX.log]];
local IJson_file = [[E:/json_script_out/skb.credithistories1.json]];

function log(m)

	---примитивный логгер, тупо пишет ошибки в файл---
	m = tostring(m)
	local ok,err =	appendfile(Logfile,m..'\r\n');
	if not ok then MsgBox(render{err,Logfile}) error'Ошибка логгирования' end;

end;

function date_transform(date)

	--log(xrender(date))
	date = string.sub(date, 1, 10)
	date = date:swap('-','.');
	date = string.split(date,'.');
	local answer = date[3]..'.'..date[2]..'.'..date[1];
	log(answer);

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
			local sum1 = (sum == loan_sum) and true or false;
			local num = tostring(doc:GetValue(3));
			local num1 = (num == loan_num) and true or false;
			local date = tostring(doc:GetValue(6));
			local date1 = (date == loan_date) and true or false;

			if (source1) and (sum1) and (num1) and (date1) then

				log('try to write'..source1..'|'..login..'//'..sum1..'|'..loan_sum..'//'..num1..'|'..loan_num..'//'..date1..'|'..loan_date..'//uuid|'..uuid)

				-- local ok = record:Lock()
				-- if ok then -- если блокировка успешна, переходим к редактированию записи?
				--
				-- 	record:SetValue(99, uuid)
				-- 	record:Update() -- сохраняем запись?
				-- 	record:Unlock() -- разблокируем запись
				--
				-- end;

			end;

		end;

	end;

end;

function recordset_worker(str_to_find, recordset, line, loan_num, loan_sum, loan_date, login, uuid)


	if recSetPerson.Count == 0 then	log('Субъекта не нашлось//'..str_to_find..'//mongo_id//'..line['_id']['$oid']);	return 1; end;
	if recSetPerson.Count > 1 then	log('Субъекта много//'..str_to_find..'//mongo_id//'..line['_id']['$oid']); 	return 1; end;

	for recPerson in recSetPerson.Records do

		credit_update(recPerson, loan_num, loan_sum, loan_date, login, uuid)
		log('Работаю с //'..str_to_find..'//mongo_id//'..line['_id']['$oid']);

	end;

	return 0;

end;

function main(file)

	for line in io.lines(file) do

		if (line ~= '[') and (line ~= ']') then

			line = line:decode('utf-8');
			line = string.sub(line, 1, #line -1)
			line = json.decode(line);
			local login = string.upper(line['userName']);

			if (line['loan']) then

				local loan_num = line['loan']['num'];
				local loan_sum = line['loan']['sum'];
				local loan_date = date_transform(line['loan']['date']['$date']);

				if line['borrower']['fl'] then

					local fname = string.upper(line['borrower']['fl']['firstName']);
					local sname = string.upper(line['borrower']['fl']['lastName']);
					local dname =s tring.upper(line['borrower']['fl']['middleName']);
					local db = date_transform(line['borrower']['fl']['dateOfBirth']['$date']);

					if (line['loan']['uuid']) and (line['loan']['uuid'] ~= '') then

						local uuid = line['loan']['uuid'];
						local str_to_find = [[ОТ ФЛ01 1 РВ ']]..SURNAME..[[' И 2 РВ ']]..NAME..[[' И 4 РВ ']]..DateOfB..[[']];
						local recSetPerson = baseFL:StringRequest(str_to_find);
						recordset_worker(str_to_find, recSetPerson, line, loan_num, loan_sum, loan_date, login, uuid)

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
							recordset_worker(str_to_find, recSetPerson, line, loan_num, loan_sum, loan_date, login, uuid)

						end;

						if (ogrn ~= '') then

							local str_to_find = [[ОТ ЮЛ01 7 РВ ']]..ogrn..[[']];
							local recSetPerson = baseUL:StringRequest(str_to_find);
							recordset_worker(str_to_find, recSetPerson, line, loan_num, loan_sum, loan_date, login, uuid)

						end;

					end;

				end;

			end;

		end;

	end;

end;

main(IJson_file)
