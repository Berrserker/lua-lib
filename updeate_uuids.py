import csv
import json
from pymongo import MongoClient
import time
import pprint
import math
import re
from datetime import timedelta
from datetime import datetime
import requests

pp = pprint.PrettyPrinter(indent=4)

three_hours = timedelta(hours=3)

client = MongoClient()
skb = client['skb']
credithistories = skb['credithistories']

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

def iter(doc):

	if doc.get('loan'):

		if doc['loan'].get('uuid'):

			# print('uid')

			uuid = str(doc['loan']['uuid'])
			tpl = '/^([0-9a-f]{8}-[0-9a-f]{4}-1[0-9a-f]{3}-[89abcdef][0-9a-f]{3}-[0-9a-f]{12})-([0-9a-f]{1})$/'

			if re.match(tpl, uuid) is not None:

				# OK
				return 0

			else:

				# Not OK
				id = doc.get('_id')
				string = ''
				string = string + str(doc['userName']) + ';'

				if doc.get('borrower').get('fl'):

					string = string + 'FL'+ ';'
					string = string + str(doc['borrower']['fl']['lastName']) + ';'
					string = string + str(doc['borrower']['fl']['lastName']) + ';'
					string = string + ';'
					db = doc['borrower']['fl']['dateOfBirth']+three_hours
					string = string + str(db.strftime('%d.%m.%Y')) + ';'

				if doc.get('borrower').get('ul'):

					string = string + 'UL'+ ';'
					string = (string + str(doc['borrower']['ul']['INN']) + ';') if (doc.get('borrower').get('ul').get('INN')) else (string + ';')
					string = (string + str(doc['borrower']['ul']['OGRN']) + ';') if (doc.get('borrower').get('ul').get('OGRN')) else (string + ';')

					if not doc.get('borrower').get('ul').get('INN') and not doc.get('borrower').get('ul').get('OGRN'):

						return 0

				string = string + str(doc['loan']['num']) + ';'

				num_date = doc['loan']['date'] + three_hours
				string = string + str(num_date.strftime('%d.%m.%Y')) + ';'

				string = string + str(doc['loan']['sum']) + ';'

				response = requests.post('https://stbureau.ru/uuid')

				json = response.json()
				uuid_new = json['uuid']
				string = string + uuid_new + ';'
				string = string + uuid + ';'

				id = doc.get('_id')
				credithistories.update_one({
				  '_id': id
				},{
				  '$set': {
				    'loan.uuid': uuid_new
				  }
				}, upsert=False)

				return string

		else:

			# print('no uid')
			return 0

	else:

		# print('no loan')
		return 0

def worker():

	path = 'answer.csv'
	f = open("path","w+")
	start = datetime(2019,10,29)
	start = start + three_hours
	b={'created': {'$gte': start}, '_state': 1}
	k = credithistories.count_documents(b)
	t = 0

	printProgressBar(0, k, 0, prefix = 'Progress:', suffix = 'Complete', length = 50)
	a = 0
	time_list = []
	data_out = []

	for doc in credithistories.find(b):

		a += 1

		start_time = time.time()
		ans = iter(doc)
		if ans != 0:
			f.write(ans + '\r\n')
		time_list.append(time.time() - start_time)
		time_delta = math.fsum(time_list)/len(time_list) if len(time_list)>100 else time_list[len(time_list)-1]
		printProgressBar(a, k, time_delta, prefix = 'Progress:', suffix = 'Complete', length = 50)

	f.close()
	# csv_writer(data_out, path)

worker()
