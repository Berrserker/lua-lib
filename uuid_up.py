import csv
import json
from pymongo import MongoClient
import time
import pprint
import math
from tinydb import TinyDB, Query


pp = pprint.PrettyPrinter(indent=4)

db = TinyDB('db.json')

db = db.table('fl')

#
# filename = open('db_1.json')
# content = json.load(filename)
# content = content.get('fl')
#
# for i,key in enumerate(content):
#
# 	# pp.pprint(key)
# 	db.insert({'num':key.get('num'), 'name':key.get('name'), 'path':key.get('path')})
#
# pp.pprint('done')
# # pp.pprint(db.all())


Fruit = Query()

client = MongoClient()
skb = client['skb']
credithistories = skb['credithistories']

def test_print(test, arg):

	if test:
		pp.pprint(arg)

def test_q(test, arg, *args):

	if test:

		print(type(arg))

		if type(arg) == 'function':
			return arg(args)
		else:
			return arg

def sec_to_time(sec):

	sec = int(sec)
	h = ((sec//3600))%24
	m = (sec//60)%60
	s = sec%60

	answer = '%d:%02d:%02d'% (h, m, s)
	return answer

def printProgressBar (iteration, total, time_delta, prefix = '', suffix = '', decimals = 1, length = 100, fill = chr(9608), printEnd = "\r"):
	"""
	Call in a loop to create terminal progress bar
	@params:
		iteration   - Required  : current iteration (Int)
		total	   - Required  : total iterations (Int)
		prefix	  - Optional  : prefix string (Str)
		suffix	  - Optional  : suffix string (Str)
		decimals	- Optional  : positive number of decimals in percent complete (Int)
		length	  - Optional  : character length of bar (Int)
		fill		- Optional  : bar fill character (Str)
		printEnd	- Optional  : end character (e.g. "\r", "\r\n") (Str)
	"""
	percent = ("{0:." + str(decimals) + "f}").format(100 * (iteration / float(total)))
	filledLength = int(length * iteration // total)

	end_timer = str(math.inf)
	if (time_delta != 0):
		end_timer = int((total - iteration)*time_delta)
		end_timer = sec_to_time(end_timer)

	bar = fill * filledLength + '-' * (length - filledLength)
	print('\r%s |%s| %s%% ~=%s %s' % (prefix, bar, percent, end_timer, suffix), end = printEnd)
	# Print New Line on Complete
	if iteration == total:
		print()

def csv_writer(data, path):

	"""
	Write data to a CSV file path
	"""
	with open(path, "w", newline='') as csv_file:
		writer = csv.writer(csv_file, delimiter=';')
		for line in data:
			writer.writerow(line)



def row_executor(row):

	# pp.pprint(db.all())
	# exit()
	# document = credithistories.find_one(b)
	pp.pprint(row[2])
	is_pack = True if row[2].find('PREFIXSTSENDPACKCHNEW') != -1 else False
	pp.pprint(is_pack)
	row[2] = row[2].replace('CH#PRT040815#', '')
	start = 0
	end = row[2].find('PREFIX')
	pp.pprint(str(start)+'||'+str(end))
	id_num = row[2][start:end]
	pp.pprint(id_num)
	finder = db.search(Fruit.num == id_num)
	pp.pprint(finder)
	exit()




def row_executor_sub(row):

	i = 0
	for step in row:
		# row[i] = step[0:-1]
		print(i, step)
		i+=1
	# print(row)

	if row[16] == "Р¤Р›'" or row[16] == "Р�Рџ'":

		b={
			'loan.num': row[7][0:-1],
			'borrower.document.number': row[25][0:-1],
			'borrower.document.seria': row[24][0:-1],
			'_state':1,
		}

	else:

		b={
			'loan.num': row[7][0:-1],
			 "borrower.ul.OGRN" : row[22][0:-1],
			'_state':1,
		}

	pp.pprint(b)

	document = credithistories.find_one(b)
	pp.pprint(document)

	if not document or not document.get('loan').get('uuid'):
		return row
	else:
		return None

def iter(row, data_out, test):

	if test:
		if row_executor_sub(row):
			data_out.append(row)
	else:
		if row_executor(row):
			data_out.append(row)

def worker(test, breaker):

	in_path_test = 'Edit2.csv'
	in_path_work = 'skbfile.csv'
	flagged_path = in_path_test if test else in_path_work

	path = 'answer.csv'
	test_print(test, flagged_path)
	datafile = open(flagged_path, encoding='1251')
	data = csv.reader(datafile, delimiter = ';')
	l = sum(1 for row in data)
	test_print(test, l)
	printProgressBar(0, l, 0, prefix = 'Progress:', suffix = 'Complete', length = 50)
	datafile.close()
	datafile = open(flagged_path, encoding='1251')
	data = csv.reader(datafile, delimiter = ';')
	a = 0
	time_list = []
	data_out = []

	for row in data:

		a += 1

		start_time = time.time()
		iter(row, data_out, test)
		time_list.append(time.time() - start_time)
		time_delta = math.fsum(time_list)/len(time_list) if len(time_list)>100 else time_list[len(time_list)-1]
		test_print(test, time_delta)
		test_print(test, time_list)
		printProgressBar(a, l, time_delta, prefix = 'Progress:', suffix = 'Complete', length = 50)

		if breaker:
			break

	csv_writer(data_out, path)

# worker(True, True)
# worker(True, False)
worker(False, True)
