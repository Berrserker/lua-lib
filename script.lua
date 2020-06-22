local customBankCashe = require('sys.customBankCashe');
require 'json'
local bankName = [[SKB]];
local bankCKKI = customBankCashe.at_Bank(bankName);
local baseFL = bankCKKI:GetBase('ФЛ');
local configure = require('configurator');
local Logfile = [[E:/json_script_out/Log.log]];
local js_file = [[E:/json_script_out/out.log]];
local validate_dir = [[E:/json_script_out/validate/]];
local export_log = [[E:/json_script_out/JSON_EXPORT.log]];
local path = [[E:/json_script_out/f_o/]];
local file_subfld = [[E:/json_script_out/f_o/err/]];
--local count_in = 300;
local counter = 0;

function validate_new(info)

	if type(info) == 'table' then

		info = json.encode(info);

	end;

	local response, status;

	while true do

		response, status = HttpRequest({
			--url = 'http://195.128.125.35/api/validate',
			url = 'http://10.30.37.40/api/validate',
			verb = 'POST',
			data = info
		})

		if status == 200 then break end;

	end;

	if response:find('success')  then

		return true;

	else

		return false, response:match('error(.+)');

	end;

end;

function log_valid(m, f)

	f = validate_dir..f;
	WRITEFILE(f, json.encode(m));

end;

function log_files(m)

	---примитивный логгер, тупо пишет ошибки в файл---
	local ok,err =	appendfile(js_file,m..'\r\n');
	if not ok then MsgBox(render{err,js_file}) error'Ошибка логгирования' end;

end;

function log(m)

	---примитивный логгер, тупо пишет ошибки в файл---
	local ok,err =	appendfile(Logfile,m..'\r\n');
	if not ok then MsgBox(render{err,Logfile}) error'Ошибка логгирования' end;

end;

function copy(obj)

	if type(obj) ~= 'table' then return obj end;
	local res = {};
	for k, v in pairs(obj) do res[copy(k)] = copy(v) end;

	return res;

end;

function worker(count)

	log_files('[\n');

	local peoples = baseFL:GetRecordSet();


	for people in peoples.Records do

		local FILE = {};
		local File_er = {};
		local name = people:GetValue(2);
		local surn = people:GetValue(1);
		local birth = people:GetValue(4);

		--MsgBox(render(name, surn, birth));
		log(surn..'_'..name..'_'..birth..'\n');
		local Person = configure.Json_Configure(surn, name, birth);
		-- ОЖОГИНА_ИРИНА_02.11.1966
		-- local Person = configure.Json_Configure('ОЖОГИНА', 'ИРИНА', '02.11.1966');

		if type(Person) == 'table' then

			local flag = false;
			--MsgBox(render(Person));

			local state = {};

				state['TUTDF'] = {};
				state['TUTDF'][1] = {};

					state['TUTDF'][1]['version'] = '7.0R';
					state['TUTDF'][1]['versionDate'] = '20200415';
					state['TUTDF'][1]['segmentTag'] = 'TUTDF';
					state['TUTDF'][1]['cycleIdentification'] = '1';

				state['ID'] = Person['ID'];
				state['NA'] = Person['NA'];
				state['AD'] = Person['AD'];
				state['PN'] = (Person['PN']) and (not table.isempty(Person['PN'])) and Person['PN'] or nil;

				--MsgBox(render(state));

			if (Person['IP']) and (not table.isempty(Person['IP'])) then

				flag = true;

				--MsgBox(render(Person['IP']));

				for IP in pairs(Person['IP']) do

					local sub_writer = {};
					sub_writer = copy(state);

					sub_writer['TUTDF'][1]['userName'] = Person['IP'][IP]['userName'];
					sub_writer['TUTDF'][1]['reportedDate'] = Person['IP'][IP]['dateReported'];
					sub_writer['TUTDF'][1]['authorizationCode'] = Person['IP'][IP]['userName'];
					sub_writer['IP'] = {};
					sub_writer['IP'][1] = Person['IP'][IP];

					if ((sub_writer['TUTDF'][1]['reportedDate']) and (sub_writer['TUTDF'][1]['reportedDate'] == '')) then

						table.insert(File_er, sub_writer);

					else

						table.insert(FILE, sub_writer);

					end;

					--MsgBox(render(sub_writer))
					--error 'STOP'

				end;

			end;

			if (Person['TR']) and (not table.isempty(Person['TR'])) then

				--MsgBox(render(Person['TR']));

				flag = true;

				for TR in pairs(Person['TR']) do

					local sub_writer = {};
					sub_writer = copy(state);

					sub_writer['TUTDF'][1]['userName'] = Person['TR'][TR]['userName'];
					sub_writer['TUTDF'][1]['reportedDate'] = Person['TR'][TR]['dateReported'];
					sub_writer['TUTDF'][1]['authorizationCode'] = Person['TR'][TR]['userName'];
					sub_writer['TR'] = {};
					sub_writer['TR'][1] = Person['TR'][TR];

					if (Person['TR'][TR]['PA']) and (not table.isempty(Person['TR'][TR]['PA'])) then

						for PA in pairs(Person['TR'][TR]['PA']) do

							local writer = {};
							writer = copy(sub_writer);
							writer['PA'] = {};
							writer['PA'][1] = Person['TR'][TR]['PA'][PA]['toJSON'];
							writer['TR'][1]['PA'] = nil;

							--MsgBox(render(writer))
							--error 'STOP'

							if ((writer['TUTDF'][1]['reportedDate']) and (writer['TUTDF'][1]['reportedDate'] == '')) then

								table.insert(File_er, writer);

							else

								table.insert(FILE, writer);

							end;

							table.insert(FILE, writer);

						end;

					end;

					sub_writer['TR'][1]['PA'] = nil;

					if ((sub_writer['TUTDF'][1]['reportedDate']) and (sub_writer['TUTDF'][1]['reportedDate'] == '')) then

						table.insert(File_er, sub_writer);

					else

						table.insert(FILE, sub_writer);

					end;

					--MsgBox(render(sub_writer))
					--error 'STOP'

				end;

			end;

			if (not table.isempty(FILE)) then

				local file = path..name..'_'..surn..'_'..birth..[[.json]];
				local sub_file = file_subfld..name..'_'..surn..'_'..birth..[[.json]];
				function compare(a,b)

					return a[2] < b[2];

				end;

				local function sortFile(tablet)

					local items = {};
					for i in ipairs(tablet) do

						table.insert(items, {i, tablet[i]['TUTDF'][1]['reportedDate']});

					end;

					table.sort(items, compare);

					local sorted_table = {};

					for i in ipairs(items) do

						--items[i][1]


						if ((tablet[items[i][1]]['TUTDF'][1]['userName']) and (tablet[items[i][1]]['TUTDF'][1]['userName'] == '')) then

							File_er[i] = tablet[items[i][1]]

						else

							sorted_table[i] = tablet[items[i][1]];

						end;

					end;

					return sorted_table;

				end;

				FILE = sortFile(FILE);

				WRITEFILE(file, json.encode(FILE));
				WRITEFILE(sub_file, json.encode(File_er));
				-----
				local validate = {};

				for i in ipairs(FILE) do

					--table.insert(validate, configure.validate(FILE[i]));
					--local status, errors = validate_new(FILE[i]);
					--local status, errors = configure.validate(FILE[i]);

					--if not status then table.insert(validate, {['status'] = status, ['errors'] = errors}); end;
					log_files(json.encode(FILE[i])..',\n')
					--log('\n_at ='..name..'_'..surn..'_'..birth..'_validate_old_results to ='..json.encode(validate)..'\n');
					--validate = validate_new(FILE);
					--log('\n_at ='..name..'_'..surn..'_'..birth..'_validate_new_results to ='..json.encode(validate)..'\n');

				end;

				--if not table.isempty(validate) then log_valid(validate, name..'_'..surn..'_'..birth..[[.json]]); end;
				-----

			end;

			if flag then

				counter = counter + 1;
			end;

			collectgarbage();

			if counter == count then break end;

			--error 'STOP'

		end;

	end;

	--MsgBox('Done')

	log_files(']\n');

end;

configure.set_logfile(export_log);
worker(500000);
