--module(... ,package.seeall) --Удалить объявление модуля, если скрипт вызывается из интернет-компонента или планировщика.

local customBankCashe = require('sys.customBankCashe');
local bankName = [[SKB]];
local bankCKKI = customBankCashe.at_Bank(bankName);
local baseFL = bankCKKI:GetBase('ФЛ');

local function normS(s)

	s=s:swap(",",".");
	return math.modf(s);

end;

function Line_From(file)

	if not IO.File.Exists(file or "") then return {} end;

	local tS = {};
	local f=io.input(file);

	for line in f:lines() do

		table.insert(tS,line);

	end;

	f:close ();
	return tS;

end;

local Logfile = [[E:/json_script_out/sample_2000_fin/Log.log]];
local path = [[E:/json_script_out/sample_2000_fin/out/]];

function log(m)

	---примитивный логгер, тупо пишет ошибки в файл---
	local ok,err =	appendfile(Logfile, m..'\r\n');
	if not ok then MsgBox(render{err, Logfile}) error'Ошибка логгирования' end;

end;

local outFile = path.."out.csv";
writefile(outFile,"FL+db;fl_found;count_cd;ens;ens_count\r\n");

function worker(input_line_splited)

	local SURNAME = input_line_splited[4];
	local NAME = input_line_splited[5];
	local DateOfB = input_line_splited[7];
	local passport_s = input_line_splited[8];
	local passport_n = input_line_splited[9];

	local table_person = {};
	table_person['count'] = 0;
	table_person['found'] = false;
	table_person['ensurs'] = false;
	table_person['ensurs_count'] = 0;

	local str_to_find = [[ОТ ФЛ01 1 РВ ']]..SURNAME..[[' И 2 РВ ']]..NAME..[[' И 4 РВ ']]..DateOfB..[[']];
	local recSetPerson = baseFL:StringRequest(str_to_find);
	if recSetPerson.Count == 0 then	log('Лицо не нашлось');	end;
	if recSetPerson.Count > 1 then	log('Лица много'); end;

	for recPerson in recSetPerson.Records do

		table_person['found'] = true;

		local BLOCK_KD = recPerson:GetValue(300,'КД');
		local BLOCK_NC = recPerson:GetValue(300,'NC');

		local ok, result = pcall( do

			local tCredit = {};

			if BLOCK_KD.Count>0 then

				for Doc in BLOCK_KD.Records do

					local id=Doc:GetValue(2):upper()..'####'..Doc:GetValue(4)..'####'..normS(Doc:GetValue(55));

					if tCredit[id] then continue end;

					table_person['count'] = table_person['count'] + 1;

					tCredit[id]=true;

				end;

			end;

		end);

		if not ok then log('Error='..result); end;

		local ok, result = pcall( do

			if BLOCK_NC.Count>0 then

				for Doc in BLOCK_NC.Records do

					local tCredit = {};

					local id=Doc:GetValue(3):upper()..'####'..Doc:GetValue(6)..'####'..normS(Doc:GetValue(7));

					if tCredit[id] then continue end;

					table_person['count'] = table_person['count'] + 1;

					local EnsRaw = Doc:GetValue(600,'EN');

					if EnsRaw.Count>0 then

						table_person['ensurs'] = true;
						table_person['ensurs_count'] = table_person['ensurs_count'] + EnsRaw.Count;

					end;

					tCredit[id]=true;

				end;

			end;

		end);

		if not ok then log('Error='..result); end;

		break;

	end;

	local ok,err = appendfile(outFile, SURNAME..NAME..DateOfB..';'..tostring(table_person['found'])..';'..tostring(table_person['count'])..';'..tostring(table_person['ensurs'])..';'..tostring(table_person['ensurs_count'])..'\r\n');
	if not ok then log(outFile..'=write falld='..err); end;
	-- log(SURNAME..NAME..DateOfB..';'..tostring(table_person['found'])..';'..tostring(table_person['count'])..';'..tostring(table_person['ensurs'])..';'..tostring(table_person['ensurs_count'])..'\r\n');

	-- break;

end;

function start_work(currentFile)

	local UniTable = Line_From(currentFile);

	if #UniTable>0 then

		for line in ipairs(UniTable) do

			local splited = UniTable[line]:split(";")
			worker(splited);

		end;

	end;

end;

local currentFile = ThisAction.FullFileName;
start_work(currentFile);
