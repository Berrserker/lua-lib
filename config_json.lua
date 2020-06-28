module(... ,package.seeall) --Удалить объявление модуля, если скрипт вызывается из интернет-компонента или планировщика.

local customBankCashe = require('sys.customBankCashe');
local bankName = [[SKB]];
local bankCKKI = customBankCashe.at_Bank(bankName);
local baseFL = bankCKKI:GetBase('ФЛ');
local baseSourse = bankCKKI:GetBase('ИС');
local Logfile = [[C:/JSON_EXPORT.log]];
local clock = os.clock

function set_logfile(file)

	Logfile = file;

end;

function rejectReason(v)

	v = ((v) and (tostring(v))) or (nil);
	return ((v ~= '99') and (v ~= '') and (v)) or ((v == '99') and ('5')) or ('5')

end;

function math.sign(v)

	return (v >= 0 and 1) or -1;

end;

function math.round(v, bracket)

	bracket = bracket or 1;

	if not v then

		return '0';

	else

		v = tonumber(v);
		return math.floor(v/bracket + math.sign(v) * 0.5) * bracket;

	end;

end;

function region(value)

	--OKATO?OKTMO => kod regiona

	local conv_table = {
		['35'] = '91',
		['77'] = '87',
		['99'] = '79',
		['40'] = '78',
		['45'] = '77',
		['78'] = '76',
		['76'] = '75',
		['75'] = '74',
		['73'] = '73',
		['71'] = '72',
		['70'] = '71',
		['69'] = '70',
		['28'] = '69',
		['68'] = '68',
		['66'] = '67',
		['65'] = '66',
		['64'] = '65',
		['63'] = '64',
		['36'] = '63',
		['61'] = '62',
		['60'] = '61',
		['58'] = '60',
		['57'] = '59',
		['56'] = '58',
		['54'] = '57',
		['53'] = '56',
		['52'] = '55',
		['50'] = '54',
		['49'] = '53',
		['22'] = '52',
		['47'] = '51',
		['46'] = '50',
		['44'] = '49',
		['42'] = '48',
		['41'] = '47',
		['38'] = '46',
		['37'] = '45',
		['34'] = '44',
		['33'] = '43',
		['32'] = '42',
		['30'] = '41',
		['29'] = '40',
		['27'] = '39',
		['25'] = '38',
		['24'] = '37',
		['20'] = '36',
		['19'] = '35',
		['18'] = '34',
		['17'] = '33',
		['15'] = '32',
		['14'] = '31',
		['12'] = '30',
		['11'] = '29',
		['10'] = '28',
		['8'] = '27',
		['7'] = '26',
		['5'] = '25',
		['4'] = '24',
		['3'] = '23',
		['1'] = '22',
		['97'] = '21',
		['96'] = '20',
		['95'] = '19',
		['94'] = '18',
		['93'] = '17',
		['92'] = '16',
		['90'] = '15',
		['98'] = '14',
		['89'] = '13',
		['88'] = '12',
		['87'] = '11',
		['86'] = '10',
		['91'] = '09',
		['85'] = '08',
		['83'] = '07',
		['26'] = '06',
		['82'] = '05',
		['84'] = '04',
		['81'] = '03',
		['80'] = '02',
		['79'] = '01',
	};

	return conv_table[value];

end;

function sleep(n)  -- seconds

  local t0 = clock()
  while clock() - t0 <= n/20 do end

end;

function validate(info)

	local url = [[http://10.30.37.40/api/validate]]
	--local url = [[https://195.128.125.35/api/validate]]
	info = json.encode(info);
	info = string.encode(info, 'utf-8');

	local answer, httpStatus, errText, winErrCode  = HttpRequest {
		url = url, -- URL ресурса
		timeout = 10000, -- время ожидания получения ответа (10 сек.)
		verb = 'POST', -- запрос выполняется методом POST
		data = info, --request,-- передаваемые данные
		headers = { -- таблица заголовков запроса
			['Content-Length'] = string.len(info),
			['Content-Type'] = 'application/json; charset=utf-8',
		}
	}
	----log(xrender(answer, httpStatus, errText, winErrCode))
	local ok, res = pcall(do
		answer = string.decode(info, 'utf-8')
		answer = json.decode(answer);
	end)
	----log(xrender(answer))
	if not ok then log(render('ашибка запроса', res, answer, httpStatus, errText, winErrCode)) end

	if answer['status'] and answer['status'] == 'success' then return true else return false, answer['errors'] and answer['errors'] or 'ERRAR' end;

end;

function uuid()

	local url = [[https://10.30.37.30/uuid]];

	--sleep(1);

	--local answerF = nil;
	--local xounter = 0;

	--while answerF == nil do

		--local request = ''
		--xounter = xounter + 1;
		local answer, httpStatus, errText, winErrCode  = HttpRequest {
			url = url, -- URL ресурса
			timeout = 10000, -- время ожидания получения ответа (10 сек.)
			verb = 'POST', -- запрос выполняется методом POST
			data = '{}', --request,-- передаваемые данные
			headers = { -- таблица заголовков запроса
				['Content-Length'] = string.len(''),
				['Content-Type'] = 'application/json; charset=utf-8',
			}
		}
		--log(xrender(answer, httpStatus, errText, winErrCode))
		--log(xrender(answer['uuid']))
		--error 'SDASD'
		--if xounter == 10 then answer = [[{'uuid':'tutapusta1122334455'}]]; log(render('uuid ne vernulsya', answerF, answer, httpStatus, errText, winErrCode)) end;
		--answerF = answer;

	--end

	--answer = json.decode(answerF ~= nil and answerF or [[{'uuid':'tutapusta1122334455'}]]);
	answer = json.decode(answer ~= nil and answer or [[{'uuid':'tutapusta1122334455'}]]);
	log('uuid received ='..render(answer))

	return answer['uuid'];

end;

local function GuarVolume(value)

	local conv_table = {
		['1'] = 'F',
		['2'] = 'P',
	};

	return conv_table[value];

end;

local transformApplicationMethod={['1']='3', ['2']='2', ['3']='1'}
local transformRefusalReason={['1']='3', ['2']='2', ['3']='4', ['4']='6', ['99']='9'}
local transformCreditType={
	['16']=19, ['01']=1, ['06']=3, ['05']=6, ['17']=99, ['50']=12, ['51']=13, ['20']=14, ['53']=5,
	['99']=99, ['25']=14, ['200']=5, ['101']=1, ['102']=1, ['201']=4, ['202']=4, ['203']=4, ['204']=4,
	['301']=5, ['302']=5, ['303']=5, ['304']=5, ['305']=5, ['306']=5, ['401']=5, ['402']=5, ['403']=5,
	['404']=5, ['405']=5, ['406']=5, ['407']=5, ['408']=5, ['501']=3, ['601']=6, ['999']=99, ['04']=2,
	['07']=4, ['09']=5, ['10']=6, ['11']=7, ['12']=8, ['13']=9, ['14']=11, ['15']=11
}

local tCode={
	['101']=true, ['102']=true, ['201']=true, ['202']=true, ['203']=true, ['204']=true, ['301']=true, ['302']=true,
	['303']=true, ['304']=true, ['305']=true, ['306']=true, ['401']=true, ['402']=true, ['403']=true, ['404']=true,
	['405']=true, ['406']=true, ['407']=true, ['408']=true, ['501']=true, ['601']=true
}

local function getCreditType(ct,code)

		if ct=='1' then -- если это кредитная организация

			if tCode[code] then return code else return '999' end;

		else

			return '200';

		end;

end;

local function raitinengen(value)

	if (not value) or (value == '') then value = '1' end;

	local conv_table = {

	['1'] = '00',
	['2'] = '12',
	['3'] = '13',
	['4'] = '14',
	['5'] = '21',
	['6'] = '52',
	['7'] = '61',
	['8'] = '85',
	['9'] = '70',
	['99'] = '95',

	};

	return conv_table[value];

end;

local function accountTyper(value)

	local conv_table = {

	['200'] = '09',
	['101'] = '01',
	['102'] = '01',
	['201'] = '09',
	['202'] = '09',
	['203'] = '09',
	['204'] = '09',
	['301'] = '09',
	['302'] = '09',
	['303'] = '09',
	['304'] = '09',
	['305'] = '09',
	['306'] = '09',
	['401'] = '09',
	['402'] = '09',
	['403'] = '09',
	['404'] = '09',
	['405'] = '09',
	['406'] = '09',
	['407'] = '09',
	['408'] = '09',
	['501'] = '06',
	['601'] = '10',
	['999'] = '01',
	['01'] = '01',
	['04'] = '04',
	['06'] = '06',
	['07'] = '07',
	['09'] = '09',
	['10'] = '10',
	['11'] = '11',
	['12'] = '12',
	['13'] = '13',
	['14'] = '14',
	['15'] = '15',
	['16'] = '16',
	['17'] = '17',
	['18'] = '18',
	};

	return conv_table[value] and conv_table[value] or tostring(transformCreditType[value]) and transformCreditType[value] or '09';

end;

local function Id_typer(value)

	local conv_table = {

	['1'] = '21',
	['2'] = '99',
	['3'] = '04',
	['4'] = '07',
	['5'] = '26',
	['6'] = '10',
	['7'] = '15',
	['8'] = '12',
	['9'] = '15',
	['10'] = '13',
	['11'] = '14',
	['12'] = '99',
	['13'] = '22',
	['14'] = '01',
	['15'] = '02',
	['16'] = '27',
	['17'] = '31',

	};

	return conv_table[value];

end

local function toUSd(str)

	if not str then return '' end;
	local date=DateTime ( str );
	if not date.IsValid then return '' end;

	return date:ToString('%Y%m%d');

end;

function date_to_TOTDF(string)

	return toUSd(string) ~= '' and tonumber(toUSd(string)) > 19000101 and toUSd(string) or '19000202';

end;

function log(m)

	---примитивный логгер, тупо пишет ошибки в файл---
	local ok,err =	appendfile(Logfile,m..'\r\n')
	if not ok then MsgBox(render{err,Logfile}) error'Ошибка логгирования' end

end;

local function OldBase_Guarantor(N_order_guarantor)

	---тип организации в словарь TUTDF---
	---временное решение, мб потом переделаяю---
	local answer = 'N';
	if N_order_guarantor then answer = 'G'; end;
	return answer;

end;

local function Creditor_Type_Converter(mfo, kpk, skpk, ko)

	---тип организации в словарь TUTDF---
	local answer = 2;
	if tostring(mfo) == '1' then answer = 2; end;
	if tostring(kpk) == '1' then answer = 3; end;
	if tostring(skpk) == '1' then answer = 3; end;
	if tostring(ko) == '1' then answer = 1; end;

	return answer;

end;

local function Source_Rec_Found(SOURCE_ID)

	---получаем логин и ищем по логину, скопировал как у Чуфистова. Беру 1 попавшуюся запись в источниках---
	SOURCE_ID=SOURCE_ID:upper();
	SOURCE_ID=SOURCE_ID:swap('PRT040815',''):swap('PRT040814','');
	--MsgBox(SOURCE_ID)
	local STR_REQ=[[ОТ ИС01 3 РВ ']]..SOURCE_ID..[[']];
	local SourseRecSet=baseSourse:StringRequest(STR_REQ);
	--MsgBox(SourseRecSet.Count)

	local SOURCE_RAW = 0;

	if SourseRecSet.Count>0 then

		for rw in SourseRecSet.Records do

			SOURCE_RAW = rw;

		end;

	end;

	return SOURCE_RAW;

end;

local function Get_Input_Xml_Info(input_xml, input_source)

	---получаем запись в таблице 'реестр xml'&&'источники' возвращаем таблицу с данными (источник + xml)---
	local INFO = {};

	---все из 'реестр xml'---
	INFO['Date_Load'] = input_xml:GetValue(1);
	INFO['Time_Load'] = input_xml:GetValue(2);
	INFO['Time_To_Create_Message'] = input_xml:GetValue(9);
	INFO['ID_Pack'] = input_xml:GetValue(3);
	INFO['ID_XML'] = input_xml:GetValue(8);
	INFO['File'] = input_xml:GetValue(4);
	INFO['Copy_File'] = input_xml:GetValue(16);
	INFO['Source_Of_File'] = input_xml:GetValue(10);
	INFO['Source_In_File'] = input_xml:GetValue(11); --источник
	INFO['Distrib_ID'] = input_xml:GetValue(21);
	INFO['Status'] = input_xml:GetValue(5);
	INFO['Error'] = input_xml:GetValue(6);
	INFO['Similarity'] = input_xml:GetValue(15);
	INFO['Act'] = input_xml:GetValue(14);
	INFO['Description'] = input_xml:GetValue(17);
	INFO['Original_Format'] = input_xml:GetValue(18);
	--INFO['RECORDS'] = input_xml;

	INFO['CREDITOR_TYPE'] = '1';

	---все из 'источник'

	if input_source and input_source ~= 0 then

		INFO['Source'] = {};
		INFO['Source']['Date_Create'] = input_source:GetValue(1);
		INFO['Source']['Time_Create'] = input_source:GetValue(2);
		INFO['Source']['ID_Source'] = input_source:GetValue(3); --логин
		INFO['Source']['Full_Name'] = input_source:GetValue(4);
		INFO['Source']['Short_Name'] = input_source:GetValue(5);
		INFO['Source']['OGRN'] = input_source:GetValue(6);
		INFO['Source']['INN'] = input_source:GetValue(7);
		INFO['Source']['Adress'] = input_source:GetValue(8);
		INFO['Source']['Contacts'] = input_source:GetValue(9); --источник
		INFO['Source']['Unvisible'] = input_source:GetValue(10);
		INFO['Source']['Region'] = input_source:GetValue(11);
		INFO['Source']['MFO'] = input_source:GetValue(12);
		INFO['Source']['KPK'] = input_source:GetValue(13);
		INFO['Source']['SKPK'] = input_source:GetValue(14);
		INFO['Source']['KO'] = input_source:GetValue(15);
		INFO['Source']['Eliminated'] = input_source:GetValue(16);
		INFO['Source']['Type_NFO'] = input_source:GetValue(17);
		INFO['Source']['MAIL'] = input_source:GetValue(20);

		INFO['CREDITOR_TYPE'] = tostring(Creditor_Type_Converter(INFO['Source']['MFO'], INFO['Source']['KPK'], INFO['Source']['SKPK'], INFO['Source']['KO']));

		--MsgBox('CRTYPE_'..INFO['CREDITOR_TYPE']..'/    convAnsw/'..tostring(Creditor_Type_Converter(INFO['Source']['MFO'], INFO['Source']['KPK'], INFO['Source']['SKPK'], INFO['Source']['KO'])));
		--error 'Otladka'

	end;

	return INFO;

end;

local function Get_Address(DOCS)

	---получаем запись в таблице 'документы', находим 1 попавшийся адресс регистрации?фактический, возвращаем таблицу с 2 этими записями. Чтобы не пробегать весь список, а только до нахождения фактического адреса вываливаемся по флагу---
	---добавь проверкау на 0(отсутствие) записей---
	local ADDRESS1 = {};
	local ADDRESS2 = {};
	local FLAG_REG_ADR = 0;
	local FLAG_ACT_ADR = 0;

	for Doc in DOCS.Records do

		if Doc:GetValue(9) then

			if  (FLAG_REG_ADR)==0 and tostring(Doc:GetValue(9,1,false)) == '1' then table.insert(ADDRESS1, Doc); FLAG_REG_ADR = 1; end;
			if  (FLAG_ACT_ADR)==0 and tostring(Doc:GetValue(9,1,false)) == '2' then table.insert(ADDRESS2, Doc); FLAG_ACT_ADR = 1; end;

		end;
		if not Doc:GetValue(9) then table.insert(ADDRESS1, Doc); table.insert(ADDRESS2, Doc); FLAG_REG_ADR = 1; FLAG_ACT_ADR = 1; end;
		--if(FLAG_REG_ADR)==1 and (FLAG_ACT_ADR)==1 then break; end;

	end;

	if (FLAG_ACT_ADR)==0 then table.insert(ADDRESS2, ADDRESS1); end;
	if (FLAG_REG_ADR)==0 then table.insert(ADDRESS1, ADDRESS2); end;

	return ADDRESS1,ADDRESS2;

end;

local function GetBG(tbl)

	---получает номер договора, возвращает к нему таблицу гарантий + главную (по сумме), таблицу INFO для старой и новой баз КД---
	local answer = {};
	answer['BG'] = {};
	answer['Main'] = {};
	answer['Main']['Summ_BG'] = 0;
	local BG_raw = '';

	if tbl['N_doc'] then

		local baseBG = bankCKKI:GetBase('BG');
		local str_to_find = [[ОТ BG01 2 РВ ']]..tbl['N_doc']..[[']];
		BG_raw = baseBG:StringRequest(str_to_find);

	end;

	if tbl['BG_raw'] then

		BG_raw = tbl['BG_raw'];

	end;

	if (not BG_raw == nil) and (BG_raw.Count>0) then

		for Doc in BG_raw.Records do

			local INPUT = {};
			local INPUT_RAW = Doc:GetValue(310,'РЕ');
			local SOURCE_ID = ''

			for rw in INPUT_RAW.Records do

				SOURCE_ID = rw:GetValue(11);
				SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
				table.insert(INPUT, Get_Input_Xml_Info(rw, SOURCE_RAW));

			end;

			local BG = {};
			BG['V_BG'] = Doc:GetValue(1);
			BG['N_BG'] = Doc:GetValue(2);
			BG['Summ_BG'] = Doc:GetValue(3);
			BG['Curr_BG'] = Doc:GetValue(4);
			BG['Date_Start_BG'] = Doc:GetValue(5);
			BG['Date_End_BG'] = Doc:GetValue(6);
			BG['Date_End_Optional_BG'] = Doc:GetValue(7);
			BG['Why-end_Optional_BG'] = Doc:GetValue(8);

			BG['toJSON'] = {};
			BG['toJSON']['VolumeOfDebtSecuredByBankGuarantee'] = BG['V_BG'];
			BG['toJSON']['BankGuaranteeAgreementNumber'] = BG['N_BG'];
			BG['toJSON']['BankGuaranteeSum'] = tostring(math.round(BG['Summ_BG']));
			BG['toJSON']['BankGuaranteeTerm'] = date_to_TOTDF(BG['Date_End_Optional_BG'] or BG['Date_End_BG']);
			BG['toJSON']['OtherGuaranteeTerminationReasons'] = BG['Why-end_Optional_BG'];
			BG['toJSON']['CurrencyCode'] = BG['Curr_BG'];

			BG['INFO'] = INPUT;

			table.insert(answer['BG'], BG);

			if tonumber(BG['Summ_BG'])>tonumber(answer['Main']['Summ_BG']) then answer['Main'] = BG; end;

		end;

	end;

	answer['Main']['Flag'] = 'N';
	if answer['Main']['Summ_BG'] and answer['Main']['Summ_BG'] ~= 0 then answer['Main']['Flag'] = 'B'; end;

	return answer;

end;

local function Get_PA(N_doc)

	---получает номер договора, возвращает к нему таблицу поручителей + главного (по сумме), таблицу INFO для старой и новой баз КД---

end;

local function Get_Guarantors(N_doc)

	---получает номер договора, возвращает к нему таблицу поручителей + главного (по сумме), таблицу INFO для старой и новой баз КД---
	local answer = {};
	answer['GR'] = {};
	answer['Main'] = {};
	answer['Main']['Summ_GR'] = 0;
	local baseGR = bankCKKI:GetBase('ПР');
	local str_to_find = [[ОТ ПР01 7 РВ ']]..N_doc..[[']];
	log(str_to_find)
	local recSetGR = baseGR:StringRequest(str_to_find);

	for Doc in recSetGR.Records do

		local INPUT = {};
        local INPUT_RAW = Doc:GetValue(310,'РЕ');
        local SOURCE_ID = ''

        for rw in INPUT_RAW.Records do

            SOURCE_ID = rw:GetValue(11);
            SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
            table.insert(INPUT, Get_Input_Xml_Info(rw, SOURCE_RAW));

        end;

		local GR = {};
		GR['N_GR'] = Doc:GetValue(2);
		GR['N_CR_GR'] = Doc:GetValue(7);
		GR['Date_Start_GR'] = Doc:GetValue(5);
		GR['Date_End_GR'] = Doc:GetValue(6);
		GR['Summ_GR'] = Doc:GetValue(3);
		GR['V_GR'] = tostring(Doc:GetValue(1,1,false));
		GR['Curr_GR'] = Doc:GetValue(4);
		GR['V_Perc_GR'] = Doc:GetValue(8);

		GR['toJSON'] = {};
		GR['toJSON']['GuaranteeAgreementNumber'] = GR['N_GR'];
		GR['toJSON']['VolumeOfDebtSecuredByGuarantee'] = GR['V_GR'];
		GR['toJSON']['GuaranteeSum'] = tostring(math.round(GR['Summ_GR']));
		GR['toJSON']['GuaranteeTerm'] = date_to_TOTDF(GR['Date_End_GR']);
		GR['toJSON']['CurrencyCode'] = GR['Curr_GR'];


		GR['INFO'] = INPUT;

		table.insert(answer['GR'], GR);

		if tonumber(GR['Summ_GR'])>tonumber(answer['Main']['Summ_GR']) then answer['Main'] = GR; end;

	end;

	answer['Main']['Flag'] = 'N';
	if answer['Main']['Summ_GR'] and answer['Main']['Summ_GR']~= 0 then answer['Main']['Flag'] = 'G'; end;

	return answer;

end;

local function Get_Additional_Blocks(tbl)

	---получаем таблицу вида: ссылка на просрочки|платежи|залог|судебные разбирательства---
	---возвращает таблицу для json на каждый входной var и таблицу INFO к нему
	local answer = {};

	if tbl['PD'] then

		answer['PD'] = {};
		answer['PD_last'] = {};
		answer['PD_last']['Date_Of_Sum_PD'] = '02.02.1900';
		for Doc in tbl['PD'].Records do

			local INPUT = {};
			local INPUT_RAW = Doc:GetValue(310,'РЕ');
			local SOURCE_ID = ''

			for rw in INPUT_RAW.Records do

				SOURCE_ID = rw:GetValue(11);
				SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
				table.insert(INPUT, Get_Input_Xml_Info(rw, SOURCE_RAW));

			end;

			local PD = {};
			PD['Date_Of_Sum_PD'] = Doc:GetValue(5);
			PD['Full_Summ_PD'] = tostring(math.round(Doc:GetValue(1)));
			PD['Long_Of_PD'] = Doc:GetValue(2);
			PD['Date_of_Start_PD'] = Doc:GetValue(3);
			PD['Date_of_End_PD'] = Doc:GetValue(4);
			PD['Date_of_Past_PD'] = Doc:GetValue(6);
			PD['Date_of_PercentIN-flag_PD'] = Doc:GetValue(7);
			PD['INFO'] = INPUT;
			table.insert(answer['PD'], PD);

			if DateTime(PD['Date_Of_Sum_PD'])>DateTime(answer['PD_last']['Date_Of_Sum_PD']) then answer['PD_last'] = PD; end;

		end;

	end;

	if tbl['PA'] then

		answer['PA'] = {};
		answer['PA_last'] = {};
		answer['PA_last']['Date_Of_PA'] = '02.02.1900';
		for Doc in tbl['PA'].Records do

			local INPUT = {};
			local INPUT_RAW = Doc:GetValue(310,'РЕ');
			local SOURCE_ID = ''

			for rw in INPUT_RAW.Records do

				SOURCE_ID = rw:GetValue(11);
				SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
				table.insert(INPUT, Get_Input_Xml_Info(rw, SOURCE_RAW));

			end;

			local PA = {};
			PA['Date_Of_PA'] = Doc:GetValue(5);
			PA['Date_Of_Next_PA'] = date_to_TOTDF(Doc:GetValue(1));
			PA['Summ_Of_Next_PA'] = Doc:GetValue(2);
			PA['Summ_Of_Next_PA_Main'] = Doc:GetValue(3);
			PA['Summ_Of_Next_PA_Perc'] = Doc:GetValue(4);
			PA['Summ_Of_PA'] = Doc:GetValue(6);
			PA['Summ_Of_PA_Main'] = Doc:GetValue(7);
			PA['Summ_Of_PA_WF-PD'] = Doc:GetValue(12);
			PA['V_Of_PA_'] = tostring(Doc:GetValue(13)) == 'ПОЛНОСТЬЮ' and 'F' or tostring(Doc:GetValue(13)) == 'НЕ ПОЛНОСТЬЮ' and 'P' or 'N'
			PA['Summ_Of_Now-Now_Main'] = Doc:GetValue(9);
			PA['Summ_Of_Now-Now_Perc'] = Doc:GetValue(18);
			PA['Summ_Of_Now-Now_Other'] = Doc:GetValue(19);
			PA['Balans'] = Doc:GetValue(10);
			PA['Summ_12m_PA'] = Doc:GetValue(14);
			PA['Q_12m_PA'] = Doc:GetValue(15);
			PA['Summ_24m_PA'] = Doc:GetValue(16);
			PA['Q_24m_PA'] = Doc:GetValue(17);
			PA['PD_Main'] = Doc:GetValue(20);
			PA['PD_Perc'] = Doc:GetValue(21);
			PA['PD_Other'] = Doc:GetValue(22);
			PA['PD_Summ'] = Doc:GetValue(23);

			PA['toJSON'] = {};
			PA['toJSON']['paymentAmount'] = PA['Summ_Of_PA']~='' and tostring(math.round(PA['Summ_Of_PA'])) or  tostring(999999999);
			PA['toJSON']['paymentAmountExcept30+PastDue'] = PA['Summ_Of_PA_WF-PD']~='' and tostring(math.round(PA['Summ_Of_PA_WF-PD'])) or tostring(999999999);
			PA['toJSON']['paymentCurrency'] = 'RUB';
			PA['toJSON']['paymentDate'] = PA['Date_Of_PA']~='' and tonumber(date_to_TOTDF(PA['Date_Of_PA'])) > 19000101 and date_to_TOTDF(PA['Date_Of_PA']) or '19000202';
			PA['toJSON']['paymentVolume'] = PA['V_Of_PA_']~='' and PA['V_Of_PA_'] or 'F';
			PA['toJSON']['24mPaymentAmountExcept30+PastDue'] = PA['Summ_24m_PA']~='' and tostring(math.round(PA['Summ_24m_PA'])) or tostring(999999999);

			PA['INFO'] = INPUT;
			table.insert(answer['PA'], PA);

			if DateTime(PA['Date_Of_PA'])>DateTime(answer['PA_last']['Date_Of_PA']) then answer['PA_last'] = PA; end;

		end;

	end;

	if tbl['EN'] then

		answer['EN'] = {};
		answer['EN_maks'] = {};
		answer['EN_maks']['Summ_EN'] = 0;
		answer['BG'] = {};
		answer['BG_maks'] = {};
		answer['BG_maks']['Summ_BG'] = 0;
		for Doc in tbl['EN'].Records do

			local INPUT = {};
			local INPUT_RAW = Doc:GetValue(310,'РЕ');
			local SOURCE_ID = ''

			for rw in INPUT_RAW.Records do

				SOURCE_ID = rw:GetValue(11);
				SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
				table.insert(INPUT, Get_Input_Xml_Info(rw, SOURCE_RAW));

			end;

			local EN = {};
			EN['UID_EN'] = Doc:GetValue(1);
			EN['Sub_EN'] = Doc:GetValue(2);
			EN['Descr_EN'] = Doc:GetValue(3);
			EN['Summ_EN'] = Doc:GetValue(4);
			EN['Curr_EN'] = Doc:GetValue(5);
			EN['Date_Of_Summ_EN'] = Doc:GetValue(6);
			EN['Date_Start_EN'] = Doc:GetValue(7);
			EN['Date_End_EN'] = Doc:GetValue(8);

			EN['INFO'] = INPUT;

			EN['toJSON'] = {};
			EN['toJSON']['collateralAgreementNumber'] = EN['UID_EN'];
			EN['toJSON']['collateralCode'] = EN['Sub_EN'];
			EN['toJSON']['collateralValue'] = tostring(math.round(EN['Summ_EN']));
			EN['toJSON']['collateralDate'] = date_to_TOTDF(EN['Date_Of_Summ_EN']);
			EN['toJSON']['collateralAgreementExpirationDate'] = date_to_TOTDF(EN['Date_End_EN']);
			EN['toJSON']['currencyCode'] =  EN['Curr_EN'];


			answer['BG'] = {};
			tbl_to_guarant = {}
			tbl_to_guarant['BG_raw'] = Doc:GetValue(500,'BG');
			answer['BG'] = table.insert(answer['BG'], GetBG(tbl_to_guarant));
			if tonumber(GetBG(tbl_to_guarant)['Main']['Summ_BG'])>tonumber(answer['BG_maks']['Summ_BG']) then answer['BG_maks'] = GetBG(tbl_to_guarant)['Main']; end;

			table.insert(answer['EN'], EN);

			if tonumber(EN['Summ_EN'])>tonumber(answer['EN_maks']['Summ_EN']) then answer['EN_maks'] = EN; end;
		end;

	end;

	if tbl['LE'] then

		answer['LE'] = {};
		for Doc in tbl['LE'].Records do

			local INPUT = {};
			local INPUT_RAW = Doc:GetValue(310,'РЕ');
			local SOURCE_ID = ''

			for rw in INPUT_RAW.Records do

				SOURCE_ID = rw:GetValue(11);
				SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
				table.insert(INPUT, Get_Input_Xml_Info(rw, SOURCE_RAW));

			end;

			local LE = {};
			LE['Date_Issue'] = Doc:GetValue(4);
			LE['N_Issue'] = Doc:GetValue(1);
			LE['Name_Court'] = Doc:GetValue(2);
			LE['Date_Court'] = Doc:GetValue(3);
			LE['Issued_Person'] = Doc:GetValue(5);
			LE['Decision'] = Doc:GetValue(6);
			LE['Additional'] = Doc:GetValue(7);

			LE['toJSON'] = {};
			LE['toJSON']['ClaimNumber'] = LE['N_Issue'];
			LE['toJSON']['CourtName'] = LE['Name_Court'];
			LE['toJSON']['DateReported'] = date_to_TOTDF(Doc:GetValue(100));
			LE['toJSON']['DateConsideration'] = date_to_TOTDF(LE['Date_Court']);
			LE['toJSON']['DateSatisfied'] = date_to_TOTDF(LE['Date_Court']);
			LE['toJSON']['Plaintiff'] = LE['Issued_Person'];
			LE['toJSON']['Resolution'] = LE['Decision'];

			LE['INFO'] = INPUT;
			table.insert(answer['LE'], LE);

		end;

	end;

	return answer;

end;

function Json_Configure(SURNAME, NAME, DateOfB)

	local JSON_Person = {};
	local FLAG = 1;
	local str_to_find = [[ОТ ФЛ01 1 РВ ']]..SURNAME..[[' И 2 РВ ']]..NAME..[[' И 4 РВ ']]..DateOfB..[[']];
	--MsgBox(render(bankCKKI))
	--MsgBox(render(baseFL))
	--error 'OTLADKA BASE'
	local recSetPerson = baseFL:StringRequest(str_to_find);

	--MsgBox(render(recSetPerson.Count));

	if recSetPerson.Count == 0 then	log('Лицо не нашлось');	return 'no fl'	end;
	if recSetPerson.Count > 1 then	log('Лица много');	return 'many fl'	end;

	---------STANDART PERSON BLOCK START---------
	---Необходимо добавить проверки на 0 записей---

	local JSON_ID = {};
	local JSON_NA = {};
	local JSON_AD = {};
	local JSON_PN = {};
	local JSON_IP = {};
	local JSON_TR = {};
	local JSON_BC = {};
	local JSON_LE = {};
	local JSON_ID = {};

	for recPerson in recSetPerson.Records do

		log('\nStart work at ID\n');

		local ok, result = pcall( do

			local recSetDoc=recPerson:GetValue(352,'ДК');
			local pull = {};
			for Doc in recSetDoc.Records do

				local ID = {};
				ID['idType'] = Id_typer(tostring(Doc:GetValue(1, 1, false)));
				ID['seriesNumber'] = string.sub(Doc:GetValue(2), 1, 4); --серия
				ID['idNumber'] = string.sub(Doc:GetValue(2), 5); --номер
				ID['issueDate'] = date_to_TOTDF(Doc:GetValue(4));
				ID['issueAuthority'] = Doc:GetValue(5);

				if not pull[ID['idType']..'_'..ID['seriesNumber']..'_'..ID['idNumber']] then

					table.insert(JSON_ID, ID);
					pull[ID['idType']..'_'..ID['seriesNumber']..'_'..ID['idNumber']] = true;

				end;

			end;

		end);log('ID result '..xrender(ok, result));

		log('\nStart work at NA\n');

		local NA = {};
		local ok, result = pcall( do

			NA['surName'] = recPerson:GetValue(1);
			NA['patronymicName'] = recPerson:GetValue(3) ~= '' and recPerson:GetValue(3) or nil;
			NA['firstName'] = recPerson:GetValue(2);
			NA['dateOfBirth'] = date_to_TOTDF(recPerson:GetValue(4));
			NA['placeOfBirth'] = recPerson:GetValue(5) ~= '' and recPerson:GetValue(5) or nil;
			--NA['remarks'] = '1';
			--NA['oldSurName'] = recPerson:GetValue(11);
			--NA['oldFirstName'] = recPerson:GetValue(11);
			table.insert(JSON_NA, NA);

		end);log('NA result '..xrender(ok, result));

		log('\nStart work at AD\n');

		local ok, result = pcall( do

			local recSetDoc=recPerson:GetValue(350,'АД');
			local adr1, adr2 = Get_Address(recSetDoc);

			for ttte in pairs(adr1) do

				local ad = adr1[ttte];
				local AD_REG = {};
				AD_REG['addressType'] = '1';
				AD_REG['postalCode'] = ad:GetValue(10) ~= '' and ad:GetValue(10) or nil;
				AD_REG['country'] = ad:GetValue(1) ~= '' and ad:GetValue(1) or 'RU';
				AD_REG['region'] = ad:GetValue(2,1,false) and region(ad:GetValue(2,1,false)) and region(ad:GetValue(2,1,false)) ~= '' and region(ad:GetValue(2,1,false)) or '99';
				AD_REG['district'] = ad:GetValue(3) ~= '' and ad:GetValue(3) or nil;
				AD_REG['location'] = ad:GetValue(4) ~= '' and  ad:GetValue(4) or nil;
				AD_REG['streetType'] = '28';--28 --ad:GetValue(1); --не обязательное поле
				AD_REG['street'] = ad:GetValue(5) ~= '' and ad:GetValue(5) or nil;
				AD_REG['houseNumber'] = ad:GetValue(6) ~= '' and ad:GetValue(6) or nil;
				AD_REG['block'] = ad:GetValue(7) ~= '' and ad:GetValue(7) or nil;
				AD_REG['builing'] = ad:GetValue(13) ~= '' and ad:GetValue(13) or nil;
				AD_REG['apartment'] = ad:GetValue(8) ~= '' and ad:GetValue(8) or nil;
				--AD_REG['status'] = '' --ad:GetValue(1); --не обязательное поле
				--AD_REG['since'] = '' --ad:GetValue(1); --не обязательное поле
				table.insert(JSON_AD, AD_REG);

			end;

			for ttte in pairs(adr2) do

				local ad = adr2[ttte];
				local AD_ACT = {};
				AD_ACT['addressType'] = '2';
				AD_ACT['postalCode'] = ad:GetValue(10) ~= '' and ad:GetValue(10) or nil;
				AD_ACT['country'] =ad:GetValue(1) ~= '' and ad:GetValue(1) or 'RU';
				AD_ACT['region'] = ad:GetValue(2,1,false) and region(ad:GetValue(2,1,false)) and region(ad:GetValue(2,1,false)) ~= '' and region(ad:GetValue(2,1,false)) or '99';
				AD_ACT['district'] = ad:GetValue(3) ~= '' and ad:GetValue(3) or nil;
				AD_ACT['location'] = ad:GetValue(4) ~= '' and ad:GetValue(4) or nil;
				AD_ACT['streetType'] = '28'; --ad:GetValue(1);
				AD_ACT['street'] = ad:GetValue(5) ~= '' and ad:GetValue(5) or nil;
				AD_ACT['houseNumber'] = ad:GetValue(6) ~= '' and ad:GetValue(6) or nil;
				AD_ACT['block'] = ad:GetValue(7) ~= '' and ad:GetValue(7) or nil;
				AD_ACT['builing'] = ad:GetValue(13) ~= '' and ad:GetValue(13) or nil;
				AD_ACT['apartment'] = ad:GetValue(8) ~= '' and ad:GetValue(8) or nil;
				--AD_ACT['status'] = ''; --ad:GetValue(1);
				--AD_ACT['since'] = '' --ad:GetValue(1);
				table.insert(JSON_AD, AD_ACT);

			end;

			--if table.isempty(adr1) and table.isempty(adr2) then JSON_AD[1] = {} end;

		end);log('AD result '..xrender(ok, result));

		log('\n Start work at PN \n');

		local ok, result = pcall( do

			local recSetDoc=recPerson:GetValue(351,'ТФ');
			for Doc in recSetDoc.Records do

				local PN = {};
				PN['number'] = tostring(Doc:GetValue(2)) ~= '' and tostring(Doc:GetValue(2)) or nil;
				PN['type'] = tostring(Doc:GetValue(2)) ~= '' and tostring(Doc:GetValue(1, 1, false)) or nil;

				if (PN['number']) and (PN['number'] ~= '') then

					table.insert(JSON_PN, PN);
				end;

			end;

			if recSetDoc.Count<1 then JSON_PN = nil end;

		end);log('PN result '..xrender(ok, result));

	---------STANDART PERSON BLOCK END---------

	---------CUSTOM PERSON BLOCK START---------
	---Необходимо добавить проверки на 0 записей---
	--------Находим основу для блока--------

		local BLOCK_KD = recPerson:GetValue(300,'КД');
		local BLOCK_BG = recPerson:GetValue(300,'BG');
		local BLOCK_ZV = recPerson:GetValue(300,'ЗВ');
		local BLOCK_PR = recPerson:GetValue(300,'ПР');
		local BLOCK_NC = recPerson:GetValue(300,'NC');
		local BLOCK_BC = recPerson:GetValue(361,'BF');
		local BLOCK_LE = recPerson:GetValue(362,'СР');
		--log('\n Custom Blocks \n'..xrender(BLOCK_KD.Count,BLOCK_BG.Count,BLOCK_ZV.Count,BLOCK_PR.Count,BLOCK_NC.Count,BLOCK_BC.Count,BLOCK_LE.Count));
		--local JSON_CUSTOM = {};

		--------Обработка заявки?при наличии--------
		log('\n Start work at Zv \n');

		local ok, result = pcall( do

			FLAG = 1;

			if BLOCK_ZV.Count>0 and FLAG == 1  then

				for Doc in BLOCK_ZV.Records do

					local INPUT = {};
					local INPUT_RAW = Doc:GetValue(310,'РЕ');
					local SOURCE_ID = ''

					if INPUT_RAW.Count>0 then

						for rw in INPUT_RAW.Records do

							SOURCE_ID = rw:GetValue(11);
							SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
							table.insert(INPUT, Get_Input_Xml_Info(rw, SOURCE_RAW));

						end;

					else

						SOURCE_ID = Doc:GetValue(203);
						--SOURCE_RAW = Source_Rec_Found(SOURCE_ID);

					end;

					SOURCE_ID=SOURCE_ID:swap('PRT040815',''):swap('PRT040814','');
					local IP = {};
					IP['userName'] = SOURCE_ID;
					IP['applicationNumber'] = Doc:GetValue(2) ~= '' and Doc:GetValue(2) or 'NOT_FOUND';
					IP['dateOfApplication'] = date_to_TOTDF(Doc:GetValue(3)~='' and Doc:GetValue(3) or Doc:GetValue(100));
					IP['creditorType'] = INPUT[1]['CREDITOR_TYPE'] ~= '' and INPUT[1]['CREDITOR_TYPE'] or '2';
					IP['requestedLoanType'] = tostring(Doc:GetValue(7,1,false)) ~= '' and getCreditType(tostring(IP['creditorType'], Doc:GetValue(7,1,false))) or tostring(Doc:GetValue(21,1,false)) ~= '' and getCreditType(tostring(IP['creditorType'], Doc:GetValue(21,1,false))) or '200'; --Doc:GetValue(1);
					IP['applicationShipmentWay'] = Doc:GetValue(11,1,false) ~= '' and Doc:GetValue(11,1,false) or '2';
					IP['flagOfApproval'] = (Doc:GetValue(18) and 'Y') or '';
					IP['typeFlag'] = '1';
					IP['approvalExpiration'] = IP['flagOfApproval'] ~= '' and (Doc:GetValue(4) ~= '' and date_to_TOTDF(Doc:GetValue(4)) or Doc:GetValue(100) ~= '' and date_to_TOTDF(Doc:GetValue(100)) or '19000202') or nil;
					IP['rejectedAmount'] = Doc:GetValue(16,1,false) ~= '' and Doc:GetValue(8) ~= '' and tostring(math.round(Doc:GetValue(8))) or nil;
					IP['rejectedAmountCurrency'] = Doc:GetValue(16,1,false) ~= '' and 'RUB' or nil;
					IP['rejectionDate'] = Doc:GetValue(16,1,false) ~= '' and date_to_TOTDF(Doc:GetValue(13)~='' and Doc:GetValue(13) or Doc:GetValue(100)) or nil;
					IP['rejectionReason'] = Doc:GetValue(16,1,false) ~= '' and rejectReason(Doc:GetValue(16,1,false)) or nil;
					IP['agreementNumber'] = Doc:GetValue(18) ~= '' and Doc:GetValue(18) or 'NOT_FOUND';
					IP['approvedLoanType'] = Doc:GetValue(18) ~= '' and tostring(Doc:GetValue(21,1,false)) ~= '' and tostring(Doc:GetValue(21,1,false)) or Doc:GetValue(18) ~= '' and '200' or nil;
					--IP['defaultFlag'] = Doc:GetValue(1);
					--IP['loanFullyReturnedIndicator'] = Doc:GetValue(1);
					--IP['oldApplicationNumber'] = ''; --Doc:GetValue(1);
					IP['tradeUniversallyUniqueID'] = Doc:GetValue(99)~='' and Doc:GetValue(99) or IP['dateOfApplication']>'20191029' and uuid() or nil;
					IP['dateReported'] = date_to_TOTDF(Doc:GetValue(101)~='' and Doc:GetValue(101) or Doc:GetValue(100));
					IP['INFO'] = INPUT;

					table.insert(JSON_IP, IP);

				end;

			end;
		end);log('Zv result '..xrender(ok, result));

		-- FLAG = 1;
		--
		-- log('\n Start work at Pr \n');
		-- local ok, result = pcall( do
		-- 	--------Обработка поручительства?при наличии--------
		-- 	if BLOCK_PR.Count>0 and FLAG == 1  then
		--
		-- 		for Doc in BLOCK_PR.Records do
		--
		-- 			local INPUT = {};
		-- 			local INPUT_RAW = Doc:GetValue(310,'РЕ');
		-- 			local SOURCE_ID = ''
		--
		-- 			if INPUT_RAW.Count>0 then
		--
		-- 				for rw in INPUT_RAW.Records do
		--
		-- 					SOURCE_ID = rw:GetValue(11);
		-- 					SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
		-- 					table.insert(INPUT, Get_Input_Xml_Info(rw, SOURCE_RAW));
		--
		-- 				end;
		--
		-- 			else
		--
		-- 				SOURCE_ID = Doc:GetValue(203);
		-- 				--SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
		--
		-- 			end;
		--
		-- 			SOURCE_ID=SOURCE_ID:swap('PRT040815',''):swap('PRT040814','');
		-- 			TR['userName'] = SOURCE_ID;
		-- 			TR['accountNumber'] = Doc:GetValue(2) ~='' and Doc:GetValue(2) or 'NOT_FOUND';
		-- 			--TR['accountType'] = '';--accountTyper(tostring(Doc:GetValue(1,1,false)));
		-- 			TR['accountRelationship'] = '5';--Doc:GetValue(1);
		-- 			TR['dateAccountOpened'] = date_to_TOTDF(Doc:GetValue(5) ~='' and Doc:GetValue(5) or Doc:GetValue(100));
		-- 			--TR['dateOfLastPayment'] = '';--Doc:GetValue(11);
		-- 			--TR['accountRating'] = '';--(Doc:GetValue(18) and 'Y') or '';
		-- 			--TR['dateAccountRating'] = '';--Doc:GetValue(4);
		-- 			TR['dateReported'] = date_to_TOTDF(Doc:GetValue(101) ~='' and Doc:GetValue(101) or Doc:GetValue(100));
		-- 			--TR['creditLimitOrContractAmount'] = '';--Doc:GetValue(10);
		-- 			--TR['balance'] = '';--Doc:GetValue(10);
		-- 			--TR['pastDue'] = '';--Doc:GetValue(10);
		-- 			--TR['nextPayment'] = '';--Doc:GetValue(10);
		-- 			--TR['creditPaymentFrequency'] = '';--Doc:GetValue(10);
		-- 			--TR['MOP'] = '';--Doc:GetValue(10);
		-- 			--TR['currencyCode'] = 'RUB';
		-- 			--TR['collateralCode'] = '';--Doc:GetValue(10);
		-- 			--TR['dateOfContractTermination'] =  '';--Doc:GetValue(6);
		-- 			--TR['datePaymentDue'] = '';--Doc:GetValue(6);
		-- 			--TR['dateInterestPaymentDue'] = '';--Doc:GetValue(6);
		-- 			--TR['interestPaymentFrequency'] '';--Doc:GetValue(6);
		-- 			--TR['oldUserName'] = '';--Doc:GetValue(6);
		-- 			--TR['oldAccountNumber'] = '';--Doc:GetValue(6);
		-- 			--TR['amountOutstanding'] = Doc:GetValue(3) ~='' and Doc:GetValue(3) or '999999999'; ---???ВОПРОС???---
		-- 			--TR['guarantorIndicator'] = '';--Doc:GetValue(6);
		-- 			TR['volumeOfDebtSecuredByGuarantee'] = tostring(Doc:GetValue(1,1,false));
		-- 			TR['guaranteeSum'] = Doc:GetValue(3) ~='' and tostring(math.round(Doc:GetValue(3))) or '999999999';
		-- 			TR['guaranteeTerm'] = date_to_TOTDF(Doc:GetValue(6)~='' and Doc:GetValue(6) or Doc:GetValue(100));
		-- 			--TR['bankGuaranteeIndicator'] = '';--Doc:GetValue(6)
		-- 			--TR['volumeOfDebtSecuredByBankGuarantee'] = '';--Doc:GetValue(6)
		-- 			--TR['bankGuaranteeSum'] = '';--Doc:GetValue(6)
		-- 			--TR['bankGuaranteeTerm'] = '';--Doc:GetValue(6)
		-- 			--TR['collateralValue'] = '';--Doc:GetValue(6)
		-- 			--TR['collateralDate'] = '';--Doc:GetValue(6)
		-- 			--TR['collateralAgreementExpirationDate'] = '';--Doc:GetValue(6)
		-- 			--TR['overallValueOfCredit'] = '';--Doc:GetValue(6)
		-- 			--TR['rightOfClaimAcquirersNames'] = '';--Doc:GetValue(6)
		-- 			--TR['rightOfClaimAcquirersRegistrationData'] = '';--Doc:GetValue(6)
		-- 			--TR['rightOfClaimAcquirersTaxpayerID'] = '';--Doc:GetValue(6)
		-- 			--TR['rightOfClaimAcquirersSocialInsuranceNumber'] = '';--Doc:GetValue(6)
		-- 			--TR['completePerformanceOfObligationsDate'] = '';--Doc:GetValue(6)
		-- 			--TR['principalAmountOutstandingAsOfLastPaymentDate'] = '';--Doc:GetValue(6)
		-- 			--TR['interestAmountOutstandingAsOfLastPaymentDate'] = '';--Doc:GetValue(6)
		-- 			--TR['otherAmountOutstandingAsOfLastPaymentDate'] = '';--Doc:GetValue(6)
		-- 			--TR['principalAmountPastDueAsOfLastPaymentDate'] = '';--Doc:GetValue(6)
		-- 			--TR['interestAmountPastDueAsOfLastPaymentDate'] = '';
		-- 			--TR['otherAmountPastDueAsOfLastPaymentDate'] = '';
		-- 			--TR['gracePeriodEndDate'] = '';
		-- 			TR['tradeUniversallyUniqueID'] = Doc:GetValue(99) or uuid() or 'tutapusta1122334455';
		--
		-- 			TR['INFO'] = INPUT;
		--
		-- 			table.insert(JSON_TR, TR);
		--
		-- 		end;
		--
		-- 	end;
		--
		-- end);log('Pr result '..xrender(ok, result));
		--
		-- --------Обработка займа(Старая база)при наличии--------
		-- ---???ВОПРОС пока так, надо переделывать, я хз как это делать, тут нужен Чуфистов пусть сам разбирается со своей старой базой??? надо насnроить поручительство и банковскую гарантию ??? починить платежи и просрочку ???---
		--
		-- FLAG = 0;
		--
		-- log('\n Start work at KD \n');
		-- local ok, result = pcall( do
		--
		-- 	if BLOCK_KD.Count>0 and FLAG == 1  then
		--
		-- 		for Doc in BLOCK_KD.Records do
		--
		-- 			local INPUT = {};
		-- 			local INPUT_RAW = Doc:GetValue(310,'РЕ');
		-- 			local SOURCE_ID = ''
		--
		-- 			if INPUT_RAW.Count>0 then
		--
		-- 				for rw in INPUT_RAW.Records do
		--
		-- 					SOURCE_ID = rw:GetValue(11);
		-- 					SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
		-- 					table.insert(INPUT, Get_Input_Xml_Info(rw, SOURCE_RAW));
		--
		-- 				end;
		--
		-- 			else
		--
		-- 				SOURCE_ID = Doc:GetValue(203);
		-- 				--SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
		--
		-- 			end;
		--
		-- 			SOURCE_ID=SOURCE_ID:swap('PRT040815',''):swap('PRT040814','');
		-- 			tbl_to_guarant = {};
		-- 			tbl_to_guarant['BG_raw'] = '';
		-- 			tbl_to_guarant['N_doc'] = Doc:GetValue(2);
		-- 			BG_Guarantee = GetBG(tbl_to_guarant);
		-- 			PR_Guarantor = Get_Guarantors(tbl_to_guarant['N_doc']);
		--
		-- 			local TR = {};
		--
		-- 			TR['userName'] = SOURCE_ID;
		-- 			TR['accountNumber'] = Doc:GetValue(2);
		-- 			TR['accountType'] = Doc:GetValue(1); ---???ВОПРОС мб тут поле 116???---
		-- 			TR['accountRelationship'] = '1';--Doc:GetValue(1);
		-- 			TR['dateAccountOpened'] = date_to_TOTDF(Doc:GetValue(4));
		-- 			TR['dateOfLastPayment'] = date_to_TOTDF(Doc:GetValue(5));
		-- 			TR['accountRating'] = Doc:GetValue(6)
		-- 			TR['dateAccountRating'] = date_to_TOTDF(Doc:GetValue(7));
		-- 			TR['dateReported'] = date_to_TOTDF(Doc:GetValue(7));
		-- 			TR['creditLimitOrContractAmount'] = Doc:GetValue(55);
		-- 			TR['balance'] = Doc:GetValue(9);
		-- 			TR['pastDue'] = Doc:GetValue(65);
		-- 			TR['nextPayment'] = Doc:GetValue(11);
		-- 			TR['creditPaymentFrequency'] = '';
		-- 			TR['MOP'] = Doc:GetValue(66);
		-- 			TR['currencyCode'] = Doc:GetValue(13);
		-- 			TR['collateralCode'] = Doc:GetValue(14);
		-- 			TR['dateOfContractTermination'] = date_to_TOTDF(Doc:GetValue(15));
		-- 			TR['datePaymentDue'] = date_to_TOTDF(Doc:GetValue(15));
		-- 			TR['dateInterestPaymentDue'] = date_to_TOTDF(Doc:GetValue(24));
		-- 			TR['interestPaymentFrequency'] = '';
		-- 			TR['oldUserName'] = '';
		-- 			TR['oldAccountNumber'] = '';
		-- 			TR['amountOutstanding'] = Doc:GetValue(30);
		-- 			TR['guarantorIndicator'] = PR_Guarantor['Main']['Flag'];Doc:GetValue(6);
		-- 			TR['volumeOfDebtSecuredByGuarantee'] = PR_Guarantor['Main']['V_GR'];
		-- 			TR['guaranteeSum'] = tostring(PR_Guarantor['Main']['Summ_GR']) ~= '0' and tostring(PR_Guarantor['Main']['Summ_GR']) or nil;
		-- 			TR['guaranteeTerm'] = date_to_TOTDF(PR_Guarantor['Main']['Date_End_GR']);
		-- 			TR['bankGuaranteeIndicator'] = 'N';---???ВОПРОС пока так, надо переделывать, я хз как это делать ???---
		-- 			TR['volumeOfDebtSecuredByBankGuarantee'] = 'P';---???ВОПРОС пока так, надо переделывать, я хз как это делать ???---
		-- 			TR['bankGuaranteeSum'] = 10;---???ВОПРОС пока так, надо переделывать, я хз как это делать ???---
		-- 			TR['bankGuaranteeTerm'] = date_to_TOTDF('01.01.2200');
		-- 			TR['collateralValue'] = Doc:GetValue(91);
		-- 			TR['collateralDate'] = date_to_TOTDF(Doc:GetValue(92));
		-- 			TR['collateralAgreementExpirationDate'] = date_to_TOTDF(Doc:GetValue(93));
		-- 			TR['overallValueOfCredit'] = Doc:GetValue(20);
		-- 			TR['rightOfClaimAcquirersNames'] = ((Doc:GetValue(85)) and (Doc:GetValue(85)..[[ ]]..Doc:GetValue(86)..[[ ]]..Doc:GetValue(87)..[[ ]]..Doc:GetValue(88))) or ((Doc:GetValue(76))and(Doc:GetValue(76)..[[ ]]..Doc:GetValue(77)..[[ ]]..Doc:GetValue(78)));
		-- 			TR['rightOfClaimAcquirersRegistrationData'] = ((Doc:GetValue(85)) and (Doc:GetValue(89))) or ((Doc:GetValue(76))and(Doc:GetValue(79)..[[ ]]..Doc:GetValue(80)..[[ ]]..Doc:GetValue(81)..[[ ]]..Doc:GetValue(82)));
		-- 			TR['rightOfClaimAcquirersTaxpayerID'] = ((Doc:GetValue(85)) and (Doc:GetValue(90))) or ((Doc:GetValue(76))and((Doc:GetValue(84))));
		-- 			TR['rightOfClaimAcquirersSocialInsuranceNumber'] = (Doc:GetValue(76)) and (Doc:GetValue(83)) ;
		-- 			TR['completePerformanceOfObligationsDate'] = date_to_TOTDF(Doc:GetValue(8));
		-- 			TR['principalAmountOutstandingAsOfLastPaymentDate'] = Doc:GetValue(30);
		-- 			TR['interestAmountOutstandingAsOfLastPaymentDate'] = '';
		-- 			TR['otherAmountOutstandingAsOfLastPaymentDate'] = '';
		-- 			TR['principalAmountPastDueAsOfLastPaymentDate'] = Doc:GetValue(65);
		-- 			TR['interestAmountPastDueAsOfLastPaymentDate'] = '';
		-- 			TR['otherAmountPastDueAsOfLastPaymentDate'] = '';
		-- 			TR['gracePeriodEndDate'] = '';
		-- 			TR['tradeUniversallyUniqueID'] = Doc:GetValue(99) or uuid() or 'tutapusta1122334455';
		--
		-- 			TR['INFO'] = INPUT;
		--
		-- 			TR['PA'] = {};
		--
		-- 			table.insert(JSON_TR, TR);
		--
		-- 		end;
		--
		-- 	end;
		--
		-- end);log('KD result '..xrender(ok, result));
		--
		-- FLAG = 1;

		log('\n Start work at NC \n');
		local ok, result = pcall( do

			--------Обработка займа(Новая база)?при наличии--------
			if BLOCK_NC.Count>0 and FLAG == 1  then

				for Doc in BLOCK_NC.Records do

					local INPUT = {};
					local INPUT_RAW = Doc:GetValue(310,'РЕ');
					local SOURCE_ID = ''
					if INPUT_RAW.Count>0 then

						for rw in INPUT_RAW.Records do

							SOURCE_ID = rw:GetValue(11);
							SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
							table.insert(INPUT, Get_Input_Xml_Info(rw, SOURCE_RAW));

						end;

					else

						SOURCE_ID = Doc:GetValue(203);
						--SOURCE_RAW = Source_Rec_Found(SOURCE_ID);

					end;

					SOURCE_ID=SOURCE_ID:swap('PRT040815',''):swap('PRT040814','');
					local PastDueRaw = Doc:GetValue(720,'PR');
					local PlaRaw = Doc:GetValue(400,'PL');
					local EnsRaw = Doc:GetValue(600,'EN');
					local LegalRaw = Doc:GetValue(700,'СР');
					local Table_to_ADDS = {};
					Table_to_ADDS['PD'] = PastDueRaw;
					Table_to_ADDS['PA'] = PlaRaw;
					Table_to_ADDS['EN'] = EnsRaw;
					Table_to_ADDS['LE'] = LegalRaw;
					local ADDS = {};

					-- local f,t = xpcall( do

						local ADDS = Get_Additional_Blocks(Table_to_ADDS);

					-- end, debug.traceback());

					-- if not f then log('erro adds='..t) end
					-- log([[\nTHIS IS ADDS\n]]..[[\nTHIS IS ADDS\n]])

					tbl_to_guarant = {};
					tbl_to_guarant['BG_raw'] = '';
					tbl_to_guarant['N_doc'] = Doc:GetValue(3) and Doc:GetValue(3);
					--log('BG_in_NC')
					--BG_Guarantee = GetBG(tbl_to_guarant);
					log('PR_in_NC')
					PR_Guarantor = {};

					-- local prOK, prRES = pcall( do

						PR_Guarantor = Get_Guarantors(tbl_to_guarant['N_doc']);

					-- end);

					--if not prOK then log('PRinTR error='..render(prRES)) end;
					log([[\nTHIS IS PR\n]]..[[\nTHIS IS PR\n]]);

					local TR = {};

					TR['userName'] = SOURCE_ID ~= '' and SOURCE_ID or 'NOT_FOUND';
					TR['accountNumber'] = Doc:GetValue(3) ~= '' and Doc:GetValue(3) or 'NOT_FOUND';
					TR['accountType'] = tostring(accountTyper(tostring(Doc:GetValue(1,1,false)))) ~= '' and tostring(accountTyper(tostring(Doc:GetValue(1,1,false)))) or nil;
					TR['accountRelationship'] = '1';
					TR['dateAccountOpened'] = date_to_TOTDF(Doc:GetValue(6)) ~= '' and tonumber(date_to_TOTDF(Doc:GetValue(6))) > 19000101 and date_to_TOTDF(Doc:GetValue(6)) or '19000202';
					TR['dateOfLastPayment'] = date_to_TOTDF(Doc:GetValue(16)) ~= '' and tonumber(date_to_TOTDF(Doc:GetValue(16))) > 19000101 and date_to_TOTDF(Doc:GetValue(16)) or not table.isempty(ADDS['PA_last']) and ADDS['PA_last']['toJSON']['paymentDate'] ~= '' and ADDS['PA_last']['toJSON']['paymentDate'] or '19000202';
					TR['accountRating'] = raitinengen(tostring(Doc:GetValue(12,1,false)));
					TR['dateAccountRating'] = date_to_TOTDF(Doc:GetValue(101)) ~= '' and date_to_TOTDF(Doc:GetValue(101)) or nil;
					TR['dateReported'] = date_to_TOTDF(Doc:GetValue(101) ~='' and Doc:GetValue(101) or Doc:GetValue(100)) ~= '' and date_to_TOTDF(Doc:GetValue(101) ~='' and Doc:GetValue(101) or Doc:GetValue(100)) or nil;
					TR['creditLimitOrContractAmount'] = tostring(Doc:GetValue(7)) ~= '' and tostring(math.round(Doc:GetValue(7))) or '0';
					TR['balance'] = tostring(Doc:GetValue(26)) ~= '' and tostring(math.round(Doc:GetValue(26))) or '0';
					TR['pastDue'] = tostring(Doc:GetValue(30)) ~= '' and tostring(math.round(Doc:GetValue(30))) or '0';
					TR['nextPayment'] = not table.isempty(ADDS['PA_last']) and ADDS['PA_last']['Summ_Of_Next_PA'] ~= '' and tostring(math.round(ADDS['PA_last']['Summ_Of_Next_PA'])) or nil;
					TR['creditPaymentFrequency'] = '7';--???
					TR['MOP'] = '0';--???
					TR['currencyCode'] = 'RUB';--Doc:GetValue(10);
					TR['collateralCode'] = not table.isempty(ADDS['EN_maks']) and ADDS['EN_maks']['Summ_EN'] ~= 0 and '20' or nil;
					TR['ensuranceText'] = not table.isempty(ADDS['EN_maks']) and ADDS['EN_maks']['Summ_EN'] ~= 0 and tostring(ADDS['EN_maks']['Sub_EN']) or nil;
					TR['dateInterestPaymentDue'] = date_to_TOTDF(Doc:GetValue(9)) ~= '' and date_to_TOTDF(Doc:GetValue(9)) or nil;
					TR['dateOfContractTermination'] = date_to_TOTDF(Doc:GetValue(13)) ~= '' and date_to_TOTDF(Doc:GetValue(13)) or TR['dateInterestPaymentDue'] and TR['dateInterestPaymentDue'] ~= '' and TR['dateInterestPaymentDue'] or nil;
					TR['datePaymentDue'] = date_to_TOTDF(Doc:GetValue(16)) ~= '' and date_to_TOTDF(Doc:GetValue(16)) or TR['dateInterestPaymentDue'] and TR['dateInterestPaymentDue'] ~= '' and TR['dateInterestPaymentDue'] or nil;
					--TR['interestPaymentFrequency'] = 1;
					--TR['oldUserName'] = '';
					--TR['oldAccountNumber'] = '';
					TR['amountOutstanding'] = tostring(Doc:GetValue(31)) ~= '' and tostring(math.round(Doc:GetValue(31))) or '0';
					TR['guarantorIndicator'] = not table.isempty(PR_Guarantor) and PR_Guarantor['Main']['Flag'] and PR_Guarantor['Main']['Flag'] ~='' and PR_Guarantor['Main']['Flag'] or 'N';
					TR['volumeOfDebtSecuredByGuarantee'] = not table.isempty(PR_Guarantor) and PR_Guarantor['Main']['V_GR'] and PR_Guarantor['Main']['V_GR'] ~='' and PR_Guarantor['Main']['V_GR'] or nil;
					TR['guaranteeSum'] = not table.isempty(PR_Guarantor) and tostring(PR_Guarantor['Main']['Summ_GR']) ~= '0' and tostring(math.round(PR_Guarantor['Main']['Summ_GR'])) or nil;
					TR['guaranteeTerm'] = date_to_TOTDF(not table.isempty(PR_Guarantor) and PR_Guarantor['Main']['Date_End_GR']) ~= '' and date_to_TOTDF(not table.isempty(PR_Guarantor) and PR_Guarantor['Main']['Date_End_GR']) or nil;
					TR['bankGuaranteeIndicator'] = not table.isempty(ADDS['BG_maks']) and ADDS['BG_maks']['Flag'] or 'N';
					TR['volumeOfDebtSecuredByBankGuarantee'] = not table.isempty(ADDS['BG_maks']) and ADDS['BG_maks']['V_BG'] or nil;
					TR['bankGuaranteeSum'] =  not table.isempty(ADDS['BG_maks']) and tostring(ADDS['BG_maks']['Summ_BG']) ~= '0' and tostring(math.round(ADDS['BG_maks']['Summ_BG'])) or nil;
					TR['bankGuaranteeTerm'] = not table.isempty(ADDS['BG_maks']) and tostring(ADDS['BG_maks']['Summ_BG']) ~= '0' and ADDS['BG_maks']['toJSON'] and not table.isempty(ADDS['BG_maks']['toJSON']) and ADDS['BG_maks']['toJSON']['BankGuaranteeTerm'] or nil;
					TR['collateralValue'] = not table.isempty(ADDS['EN_maks']) and tostring(ADDS['EN_maks']['Summ_EN']) ~= '0' and tostring(math.round(ADDS['EN_maks']['Summ_EN'])) or nil;
					TR['collateralDate'] = date_to_TOTDF(not table.isempty(ADDS['EN_maks']) and ADDS['EN_maks']['Date_Of_Summ_EN']) ~= '' and date_to_TOTDF(not table.isempty(ADDS['EN_maks']) and ADDS['EN_maks']['Date_Of_Summ_EN']) or nil;
					TR['collateralAgreementExpirationDate'] = date_to_TOTDF(not table.isempty(ADDS['EN_maks']) and ADDS['EN_maks']['Date_End_EN']) ~= '' and date_to_TOTDF(not table.isempty(ADDS['EN_maks']) and ADDS['EN_maks']['Date_End_EN']) or nil;
					TR['overallValueOfCredit'] = tostring(Doc:GetValue(11)) ~= '' and tostring(Doc:GetValue(11)) or nil;
					TR['rightOfClaimAcquirersNames'] = ((tostring(Doc:GetValue(61)) ~= '' ) and (Doc:GetValue(61)..[[ ]]..Doc:GetValue(62)..[[ ]]..Doc:GetValue(63))) or ((tostring(Doc:GetValue(51)) ~= '') and (Doc:GetValue(51)..[[ ]]..Doc:GetValue(52)..[[ ]]..Doc:GetValue(53)..[[ ]]..Doc:GetValue(54)..[[ ]]..Doc:GetValue(55))) or nil;
					TR['rightOfClaimAcquirersRegistrationData'] = ((tostring(Doc:GetValue(61)) ~= '' ) and (tostring(Doc:GetValue(64)))) or ((tostring(Doc:GetValue(51)) ~= '') and (Doc:GetValue(56)..[[ ]]..Doc:GetValue(57)..[[ ]]..Doc:GetValue(57))) or nil;
					TR['rightOfClaimAcquirersTaxpayerID'] = ((tostring(Doc:GetValue(61)) ~= '' ) and (tostring(Doc:GetValue(65)))) or ((tostring(Doc:GetValue(51)) ~= '') and ((tostring(Doc:GetValue(59))))) or nil;
					TR['rightOfClaimAcquirersSocialInsuranceNumber'] = (tostring(Doc:GetValue(51)) ~= '' ) and (tostring(Doc:GetValue(15))) or nil;
					TR['completePerformanceOfObligationsDate'] = date_to_TOTDF(tostring(Doc:GetValue(8)) ~= '' and tostring(Doc:GetValue(8))) or '19000202';
					TR['principalAmountOutstandingAsOfLastPaymentDate'] = tostring(Doc:GetValue(23)) ~= '' and tostring(math.round(Doc:GetValue(23))) or tostring(999999999);
					TR['interestAmountOutstandingAsOfLastPaymentDate'] = tostring(Doc:GetValue(24)) ~= '' and tostring(math.round(Doc:GetValue(24))) or tostring(999999999);
					TR['otherAmountOutstandingAsOfLastPaymentDate'] = tostring(Doc:GetValue(25)) ~= '' and tostring(math.round(Doc:GetValue(25))) or tostring(999999999);
					TR['principalAmountPastDueAsOfLastPaymentDate'] = tostring(Doc:GetValue(27)) ~= '' and tostring(math.round(Doc:GetValue(27))) or tostring(999999999);
					TR['interestAmountPastDueAsOfLastPaymentDate'] = tostring(Doc:GetValue(28)) ~= '' and tostring(math.round(Doc:GetValue(28))) or tostring(999999999);
					TR['otherAmountPastDueAsOfLastPaymentDate'] = tostring(Doc:GetValue(29)) ~= '' and tostring(math.round(Doc:GetValue(29))) or tostring(999999999);
					--TR['gracePeriodEndDate'] = '';
					TR['tradeUniversallyUniqueID'] = Doc:GetValue(99) ~= '' and Doc:GetValue(99) or TR['dateAccountOpened']>'20191029' and uuid() or nil;

					TR['INFO'] = INPUT;
					TR['ADDS'] = ADDS;
					TR['PA'] = not table.isempty(ADDS['PA']) and ADDS['PA'] or nil;

					table.insert(JSON_TR, TR);

				end;

			end;

		end);log('NC result '..xrender(ok, result));

	-- 	FLAG = 0;
	--
	-- 	log('\n Start work at BC \n');
	-- 	local ok, result = pcall( do
	-- 		--------Обработка Банкротства?при наличии--------
	--
	-- 		if BLOCK_BC.Count>0 and FLAG == 1  then
	--
	-- 			for Doc in BLOCK_BC.Records do
	--
	-- 				local BC = {};
	--
	-- 				local INPUT = {};
	-- 				local INPUT_RAW = Doc:GetValue(310,'РЕ');
	-- 				local SOURCE_ID = ''
	--
	-- 				for rw in INPUT_RAW.Records do
	--
	-- 					SOURCE_ID = rw:GetValue(11);
	-- 					SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
	-- 					table.insert(INPUT, Get_Input_Xml_Info(rw, SOURCE_RAW));
	--
	-- 				end;
	--
	-- 				SOURCE_ID=SOURCE_ID:swap('PRT040815',''):swap('PRT040814','');
	-- 				BC['userName'] = SOURCE_ID;
	-- 				BC['CaseID'] = Doc:GetValue(1);
	-- 				BC['dateReported'] = date_to_TOTDF(Doc:GetValue(101)~='' or Doc:GetValue(100));
	-- 				BC['TypeOfBankruptcyProcedure'] = Doc:GetValue(2);
	-- 				BC['DateOfInclusionOfTheBankruptcyProcedureRecordToUFRBR'] = date_to_TOTDF(Doc:GetValue(3));
	-- 				BC['BankruptcyCloseDate'] = date_to_TOTDF(Doc:GetValue(8));
	-- 				BC['AdditionalInformationOnTheBankruptcy'] = Doc:GetValue(5);
	-- 				BC['OtherAdditionalInformationOnTheBankruptcy'] = Doc:GetValue(6);
	-- 				BC['DateOfInclusionOfTheAdditionalInformationToUFRBR'] = date_to_TOTDF(Doc:GetValue(3));
	-- 				BC['FinancialManagerPowersStartDate'] = date_to_TOTDF(Doc:GetValue(7));
	-- 				BC['FinancialManagerPowersEndDate'] = date_to_TOTDF(Doc:GetValue(8));
	--
	-- 				BC['INFO'] = INFO;
	--
	-- 				table.insert(JSON_BC, BC);
	--
	-- 			end;
	--
	-- 		end;
	--
	-- 	end);log('BC result '..xrender(ok, result));
	--
	-- 	FLAG = 1;
	--
	-- 	log('\n Start work at LE\n');
	-- 	local ok, result = pcall( do
	-- 		--------Обработка Банкротства?при наличии--------
	--
	-- 		if BLOCK_LE.Count>0 and FLAG == 1 then
	--
	-- 			for Doc in BLOCK_LE.Records do
	--
	-- 				local INPUT = {};
	-- 				local INPUT_RAW = Doc:GetValue(310,'РЕ');
	-- 				local SOURCE_ID = ''
	--
	-- 				for rw in INPUT_RAW.Records do
	--
	-- 					SOURCE_ID = rw:GetValue(11);
	-- 					SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
	-- 					table.insert(INPUT, Get_Input_Xml_Info(rw, SOURCE_RAW));
	--
	-- 				end;
	--
	-- 				local LE = {};
	--
	-- 				SOURCE_ID=SOURCE_ID:swap('PRT040815',''):swap('PRT040814','');
	-- 				LE['Date_Issue'] = Doc:GetValue(4);
	-- 				LE['N_Issue'] = Doc:GetValue(1);
	-- 				LE['Name_Court'] = Doc:GetValue(2);
	-- 				LE['Date_Court'] = Doc:GetValue(3);
	-- 				LE['Issued_Person'] = Doc:GetValue(5);
	-- 				LE['Decision'] = Doc:GetValue(6);
	-- 				LE['Additional'] = Doc:GetValue(7);
	--
	-- 				LE['toJSON'] = {};
	-- 				LE['toJSON']['ClaimNumber'] = LE['N_Issue'];
	-- 				LE['toJSON']['CourtName'] = LE['Name_Court'];
	-- 				LE['toJSON']['DateReported'] = date_to_TOTDF(Doc:GetValue(100));
	-- 				LE['toJSON']['DateConsideration'] = date_to_TOTDF(LE['Date_Court']);
	-- 				LE['toJSON']['DateSatisfied'] = date_to_TOTDF(LE['Date_Court']);
	-- 				LE['toJSON']['Plaintiff'] = LE['Issued_Person'];
	-- 				LE['toJSON']['Resolution'] = LE['Decision'];
	--
	-- 				LE['INFO'] = INPUT;
	-- 				table.insert(JSON_LE, LE);
	--
	-- 			end;
	--
	-- 		end;
	--
	-- 	end);log('LE result '..xrender(ok, result));
	--
	-- 	FLAG = 0;
	--
	-- 	log('\n Start work at BG \n');
	--
	-- 	local ok, result = pcall( do
	--
	-- 		if BLOCK_BG.Count>0 and FLAG == 1  then
	--
	-- 			for Doc in BLOCK_BG.Records do
	--
	-- 				local INPUT = {};
	-- 				local INPUT_RAW = Doc:GetValue(310,'РЕ');
	-- 				local SOURCE_ID = ''
	--
	-- 				for rw in INPUT_RAW.Records do
	--
	-- 					SOURCE_ID = rw:GetValue(11);
	-- 					SOURCE_RAW = Source_Rec_Found(SOURCE_ID);
	-- 					table.insert(INPUT, Get_Input_Xml_Info(rw, SOURCE_RAW));
	--
	-- 				end;
	--
	-- 				SOURCE_ID=SOURCE_ID:swap('PRT040815',''):swap('PRT040814','');
	-- 				TR['userName'] = SOURCE_ID;
	-- 				TR['accountNumber'] = Doc:GetValue(2);
	-- 				TR['accountType'] = '';
	-- 				TR['accountRelationship'] = '6';--Doc:GetValue(1);
	-- 				TR['dateAccountOpened'] = date_to_TOTDF(Doc:GetValue(5));
	-- 				TR['dateOfLastPayment'] = '';--Doc:GetValue(11);
	-- 				TR['accountRating'] = '';--(Doc:GetValue(18) and 'Y') or '';
	-- 				TR['dateAccountRating'] = '';--Doc:GetValue(4);
	-- 				TR['dateReported'] = date_to_TOTDF(Doc:GetValue(101)~='' or Doc:GetValue(100));
	-- 				TR['creditLimitOrContractAmount'] = '';--Doc:GetValue(10);
	-- 				TR['balance'] = '';--Doc:GetValue(10);
	-- 				TR['pastDue'] = '';--Doc:GetValue(10);
	-- 				TR['nextPayment'] = '';--Doc:GetValue(10);
	-- 				TR['creditPaymentFrequency'] = '';--Doc:GetValue(10);
	-- 				TR['MOP'] = '';--Doc:GetValue(10);
	-- 				TR['currencyCode'] = 'RUB';--Doc:GetValue(4);
	-- 				TR['collateralCode'] = '';--Doc:GetValue(10);
	-- 				TR['dateOfContractTermination'] =  '';--Doc:GetValue(6);
	-- 				TR['datePaymentDue'] = '';--Doc:GetValue(6);
	-- 				TR['dateInterestPaymentDue'] = '';--Doc:GetValue(6);
	-- 				TR['interestPaymentFrequency'] '';--Doc:GetValue(6);
	-- 				TR['oldUserName'] = '';--Doc:GetValue(6);
	-- 				TR['oldAccountNumber'] = '';--Doc:GetValue(6);
	-- 				TR['amountOutstanding'] = ''; ---???ВОПРОС???---
	-- 				TR['guarantorIndicator'] = '';--Doc:GetValue(6);
	-- 				TR['volumeOfDebtSecuredByGuarantee'] = ''; --GuarVolume(tostring(Doc:GetValue(1,1,false)));
	-- 				TR['guaranteeSum'] = '';
	-- 				TR['guaranteeTerm'] = '';
	-- 				TR['bankGuaranteeIndicator'] = '';--Doc:GetValue(6)
	-- 				TR['volumeOfDebtSecuredByBankGuarantee'] = GuarVolume(tostring(Doc:GetValue(1,1,false)));--'';--Doc:GetValue(6)
	-- 				TR['bankGuaranteeSum'] = tostring( Doc:GetValue(3));--Doc:GetValue(6)
	-- 				TR['bankGuaranteeTerm'] =  date_to_TOTDF(Doc:GetValue(6));--Doc:GetValue(6)
	-- 				TR['collateralValue'] = '';--Doc:GetValue(6)
	-- 				TR['collateralDate'] = '';--Doc:GetValue(6)
	-- 				TR['collateralAgreementExpirationDate'] = '';--Doc:GetValue(6)
	-- 				TR['overallValueOfCredit'] = '';--Doc:GetValue(6)
	-- 				TR['rightOfClaimAcquirersNames'] = '';--Doc:GetValue(6)
	-- 				TR['rightOfClaimAcquirersRegistrationData'] = '';--Doc:GetValue(6)
	-- 				TR['rightOfClaimAcquirersTaxpayerID'] = '';--Doc:GetValue(6)
	-- 				TR['rightOfClaimAcquirersSocialInsuranceNumber'] = '';--Doc:GetValue(6)
	-- 				TR['completePerformanceOfObligationsDate'] = '';--Doc:GetValue(6)
	-- 				TR['principalAmountOutstandingAsOfLastPaymentDate'] = '';--Doc:GetValue(6)
	-- 				TR['interestAmountOutstandingAsOfLastPaymentDate'] = '';--Doc:GetValue(6)
	-- 				TR['otherAmountOutstandingAsOfLastPaymentDate'] = '';--Doc:GetValue(6)
	-- 				TR['principalAmountPastDueAsOfLastPaymentDate'] = '';--Doc:GetValue(6)
	-- 				TR['interestAmountPastDueAsOfLastPaymentDate'] = '';--Doc:GetValue(6)
	-- 				TR['otherAmountPastDueAsOfLastPaymentDate'] = '';--Doc:GetValue(6)
	-- 				TR['gracePeriodEndDate'] = '';--Doc:GetValue(6)
	-- 				TR['tradeUniversallyUniqueID'] = Doc:GetValue(99) or uuid() or 'tutapusta1122334455';
	--
	-- 				TR['INFO'] = INPUT;
	--
	-- 				table.insert(JSON_TR, TR);
	--
	-- 			end;
	--
	-- 		end;
	--
	-- 	end);log('BG result '..xrender(ok, result));
	--
	end;

	JSON_Person['ID'] = JSON_ID;
	JSON_Person['NA'] = JSON_NA;
	JSON_Person['AD'] = JSON_AD;
	JSON_Person['PN'] = JSON_PN;
	JSON_Person['IP'] = JSON_IP;
	JSON_Person['TR'] = JSON_TR;
	JSON_Person['BC'] = JSON_BC;
	JSON_Person['LE'] = JSON_LE;
	log('\nJSON_Person '..xrender(JSON_Person)..'\n');

	return JSON_Person;

end;
