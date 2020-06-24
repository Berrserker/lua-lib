local customBankCashe = require('sys.customBankCashe');
require 'json'
local bankName = [[SKB]];
local bankCKKI = customBankCashe.at_Bank(bankName);
local baseFL = bankCKKI:GetBase('��');
local configure = require('configurator');
local Logfile = [[E:/json_script_out/Log.log]];
local js_file = [[E:/json_script_out/out.log]];
local validate_dir = [[E:/json_script_out/validate/]];
local export_log = [[E:/json_script_out/JSON_EXPORT.log]];
local path = [[E:/json_script_out/f_o/]];
local file_subfld = [[E:/json_script_out/f_o/err/]];
--local count_in = 300;
local counter = 0;
local start_i = 0;
local i_i = 0;
local start_name = '���������_�����_24.10.1977';
local flg = false;

function split_table(filename,tab)

	local prefix = 0;
	local size = 100;

	if #tab < size then

		writefile(filename..tostring(prefix), json.encode(tab))

	else

		local writer = {};
		writer[1] = {};

		for num = 1, #tab, 1 do

			local m = math.modf(num/size)
			table.insert(writer[m+1], tab[num])
			if math.fmod(num, size) == 99 then writer[#writer+1] = {}; end;

		end;

		for ls = 1, #writer, 1 do

			writefile(filename..tostring(ls), json.encode(writer[ls]))

		end;


		-- while true do
		--   writefile(filename..tostring(prefix), table.subarray(tbl,1,size))
		--   tab = table.subarray(tab, size + 1, #size)
		--   prefix = prefix + 1
		--   if #tab < size then break end
		-- end
		-- writefile(filename..tostring(prefix), table.subarray(tbl,1,size))

	end;
end;

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

	---����������� ������, ���� ����� ������ � ����---
	local ok,err =	appendfile(js_file,m..'\r\n');
	if not ok then MsgBox(render{err,js_file}) error'������ ������������' end;

end;

function log(m)

	---����������� ������, ���� ����� ������ � ����---
	local ok,err =	appendfile(Logfile,m..'\r\n');
	if not ok then MsgBox(render{err,Logfile}) error'������ ������������' end;

end;

function copy(obj)

	if type(obj) ~= 'table' then return obj end;
	local res = {};
	for k, v in pairs(obj) do res[copy(k)] = copy(v) end;

	return res;

end;

function worker(count)

	-- log_files('[\n');

	local peoples = baseFL:GetRecordSet();

	for people in peoples.Records do

		i_i = i_i+1;
		-- local File_er = {};
		local name = people:GetValue(2);
		local surn = people:GetValue(1);
		local birth = people:GetValue(4);
		if (surn..'_'..name..'_'..birth) == start_name then flg = true; end;
		if i_i <= start_i or flg == false then continue end;
		local FILE = {};
		--MsgBox(render(name, surn, birth));
		log(surn..'_'..name..'_'..birth..'_'..tostring(i_i)..'\n');
		local Person = configure.Json_Configure(surn, name, birth);
		-- �������_�����_02.11.1966
		-- local Person = configure.Json_Configure('�������', '�����', '02.11.1966');

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

					-- if ((sub_writer['TUTDF'][1]['reportedDate']) and (sub_writer['TUTDF'][1]['reportedDate'] == '')) then
					--
					-- 	table.insert(File_er, sub_writer);
					--
					-- else

						table.insert(FILE, sub_writer);

					-- end;

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

							-- if ((writer['TUTDF'][1]['reportedDate']) and (writer['TUTDF'][1]['reportedDate'] == '')) then
							--
							-- 	table.insert(File_er, writer);
							--
							-- else

								-- table.insert(FILE, writer);

							-- end;

							table.insert(FILE, writer);

						end;

					end;

					sub_writer['TR'][1]['PA'] = nil;

					-- if ((sub_writer['TUTDF'][1]['reportedDate']) and (sub_writer['TUTDF'][1]['reportedDate'] == '')) then
					--
					-- 	table.insert(File_er, sub_writer);
					--
					-- else

						table.insert(FILE, sub_writer);

					-- end;

					--MsgBox(render(sub_writer))
					--error 'STOP'

				end;

			end;

			if (not table.isempty(FILE)) then

				local file = path..name..'_'..surn..'_'..birth..[[.json]];
				-- local sub_file = file_subfld..name..'_'..surn..'_'..birth..[[.json]];

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


						-- if ((tablet[items[i][1]]['TUTDF'][1]['userName']) and (tablet[items[i][1]]['TUTDF'][1]['userName'] == '')) then
						--
						-- 	File_er[i] = tablet[items[i][1]]
						--
						-- else

							sorted_table[i] = tablet[items[i][1]];

						-- end;

					end;

					return sorted_table;

				end;

				FILE = sortFile(FILE);

				-- WRITEFILE(file, json.encode(FILE));

				split_table(file, FILE)
				-- WRITEFILE(sub_file, json.encode(File_er));
				-----
				-- local validate = {};

				-- for i in ipairs(FILE) do
				--
				-- 	--table.insert(validate, configure.validate(FILE[i]));
				-- 	--local status, errors = validate_new(FILE[i]);
				-- 	--local status, errors = configure.validate(FILE[i]);
				--
				-- 	--if not status then table.insert(validate, {['status'] = status, ['errors'] = errors}); end;
				-- 	log_files(json.encode(FILE[i])..',\n')
				-- 	--log('\n_at ='..name..'_'..surn..'_'..birth..'_validate_old_results to ='..json.encode(validate)..'\n');
				-- 	--validate = validate_new(FILE);
				-- 	--log('\n_at ='..name..'_'..surn..'_'..birth..'_validate_new_results to ='..json.encode(validate)..'\n');
				--
				-- end;

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
