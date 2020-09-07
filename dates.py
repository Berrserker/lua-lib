import csv
from pymongo import MongoClient
import time
import pprint
import math
from datetime import timedelta
from datetime import datetime
three_hours = timedelta(hours=3)

pp = pprint.PrettyPrinter(indent=4)
client = MongoClient()
skb = client['skb']
credithistories = skb['credithistories']
pkgs = skb['pkgs']

PPrint = pp.pprint

logfile = open("magazin.log", 'w', encoding='utf_8')
logfile.close()
logfile = open("magazin.log", 'a', encoding='utf_8')


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

def log(input):
	logfile.write(str(input)+'\n')

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

	i = 0
	for step in row:
		# row[i] = step[0:-1]
		print(i, step)
		i+=1
	print(row)

	print('|||')

	b = {
		'name': row[0],
		'userName': 'st01460'
	}

	document = pkgs.find_one(b)

	if not document:

		b = {
			'name': row[0],
			'userName': 'mf01150'
		}
		document = pkgs.find_one(b)

	pp.pprint(document)

	if document:

		log("doc"+str(document))
		PPrint(b)
		d = row[3]
		t = "00:00:00"
		dt = d + " " + t
		datetime_obj = datetime.strptime(dt,'%d.%m.%Y %H:%M:%S')
		datetime_obj = datetime_obj - three_hours
		newvalues = { "$set": { "created": datetime_obj } }

		log("new"+str(newvalues))
		pkgs.update_one(b, newvalues)

		answer = []
		answer.append(document['userName'])
		answer.append(document['_id'])
		answer.append(row[3])
		return answer

def row_executor_sub(row):

	i = 0
	for step in row:
		# row[i] = step[0:-1]
		print(i, step)
		i+=1
	print(row)

	print('|||')

	b = {
		'name': row[0],
		'userName': 'st01460'
	}

	document = pkgs.find_one(b)

	if not document:

		b = {
			'name': row[0],
			'userName': 'mf01150'
		}
		document = pkgs.find_one(b)

	pp.pprint(document)

	if document:

		PPrint(b)
		newvalues = { "$set": { "created": row[3] } }

		pkgs.update_one(b, newvalues)

	return


def iter(row, data_out, test):

	if test:
		if row_executor_sub(row):
			data_out.append(row)
	else:
		if row_executor(row):
			data_out.append(row_executor(row))

def worker(test, breaker):

	# in_path_test = 'dates.csv'
	in_path_work = 'dates.csv'
	flagged_path = in_path_test if test else in_path_work

	path = 'ans_magDeneg.csv'
	test_print(test, flagged_path)
	datafile = open(flagged_path)
	data=csv.reader(datafile, delimiter = ';')
	l = sum(1 for row in data)
	test_print(test, l)
	printProgressBar(0, l, 0, prefix = 'Progress:', suffix = 'Complete', length = 50)
	datafile.close()
	datafile = open(flagged_path)
	data=csv.reader(datafile, delimiter = ';')
	a = 0
	time_list = []
	data_out = []

	for row in data:

		a+=1

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
worker(False, False)
logfile.close()
