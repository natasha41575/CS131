import sys
import asyncio
import aiohttp
import async_timeout
import json
import time

my_api_key = 'AIzaSyD3OvCxDesRz2k1IOsmI0Ex6i_79m99WPQ'

ports = {
	'Goloman': 12275,
	'Hands': 12276,
	'Holiday': 12277,
	'Welsh': 12278,
	'Wilkes': 12279
}

connection_dict = {
    'Goloman': ['Hands', 'Holiday', 'Wilkes'],
    'Hands': ['Goloman', 'Wilkes'],
    'Holiday': ['Goloman', 'Welsh', 'Wilkes'],
    'Wilkes': ['Goloman', 'Hands', 'Holiday'],
    'Welsh': ['Holiday'],
}


client_info = dict()
all_items_dict = dict()


async def output_log(message):	

	if message != None:
		try:
			server_log.write(message)
		except:
			print('could not log message: ' + message)

async def send_resp(wrtr, message):
	if message != None:
		try:
			encoded_message = message.encode()
			wrtr.write(encoded_message)
			#print("sending response: " + message + '\n')
			await wrtr.drain()
			wrtr.write_eof()
		except:
			print('error writing message: ' + message + '\n')


async def handle_iamat(clntnm, coordinates, time_received, time_sent, wrtr):
	
	def get_coordinates(coords):
		n = 0
		i = 0
		for c in coords:
			if c == '+':
				n = n + 1
			elif c == '-':
				n = n + 1
			if n == 2:
				try:
					return coords[:(i-1)], coords[i:]
				except:
					return '', ''
			i = i + 1
		return '', ''
	
	latt, lon = get_coordinates(coordinates)
	if latt == '':
		#print('invalid coordinates')
		await output_log('invalid coordinates')
		print('? ' + cmd)
		await send_resp(wrtr, '? ' + cmd)
		return None

	time_received = float(time_received)
	if clntnm in client_info and client_info[clntnm]['time command received'] > time_received:
		output_response = 'AT %s %s %s %s %s' % (srv, str(lag), clntnm, coordinates, str(time_received))
		await output_log('sending iamat response: ' + output_response + '\n')
		print(output_response)
		await send_resp(wrtr, output_response)
		return None

	lag = time_received - time_sent
	output_response = 'AT %s %s %s %s %s' % (srv, str(lag), clntnm, coordinates, str(time_received))
	await output_log('sending iamat response: ' + output_response + '\n')
	print(output_response)

	client_info[clntnm] = {
		'server': srv,
		'time difference': lag,
		'time command received': time_received,
		'latitude': latt,
		'longitude': lon
	}

	#for key in client_info[clntnm]:
		#print(key + ':', client_info[clntnm][key])
	#print('\n')
	
	await propagate(clntnm)
	await send_resp(wrtr, output_response)


async def handle_whatsat(clntnm, radius, num_results, time_received, cmd, wrtr):
	#print("handling whatsat command")

	radius = int(radius) * 1000
	response = None

	if radius > 50000:
		print('? ' + cmd)
		await output_log("radius too large" + '\n')
		await send_resp(wrtr, '? ' + cmd)
		return None

	if int(num_results) > 20:
		print('? ' + cmd)
		await output_log("Information bound too high" + '\n')
		await send_resp(wrtr, '? ' + cmd)
		return None
	
	try:
		latitude = client_info[clntnm]["latitude"]
		longitude = client_info[clntnm]["longitude"]
	except:
		await output_log('no information about client ' + clntnm + '\n\n')
		print('? ' + cmd)
		await send_resp(wrtr, '? ' + cmd)
		return None

	#print("connecting to api with lat, lon, rad: ", latitude, longitude, radius)
	await output_log("connecting to api with lat, lon, rad: " + latitude + ', ' + longitude + ', ' + str(radius) + '\n')
	location = latitude + "," + longitude
	url = 'https://maps.googleapis.com/maps/api/place/nearbysearch/json?key={0}&location={1}&radius={2}'.format(my_api_key, location, str(radius))
	
	async with aiohttp.ClientSession() as session:
		async with session.get(url) as api_resp:
			rs = await api_resp.json()
			rs['results'] = rs['results'][:int(num_results)]
			api_msg = json.dumps(rs, indent=3)

			output_response = 'AT %s %s %s %s %s\n%s' % (srv, str(client_info[clntnm]["time difference"]), clntnm, latitude + longitude, time_received, api_msg)
			x = output_response.split('\n')
			for i in x:
				if len(i) == 0:
					x.remove(i)
			output_response = '\n'.join(x)
			output_response = output_response.strip() + '\n\n'

			await output_log('sending response: \n' + output_response)
			print(output_response)
			await send_resp(wrtr, output_response)


async def handle_at(clntnm, srv, latt, lon, lag, time_received, wrtr):
	time_received = float(time_received)
	if clntnm in client_info:
		if float(client_info[clntnm]['time command received']) >= time_received: 
			#print('received duplicate at command for client ' + clntnm)
			await output_log('received duplicate at command for client ' + clntnm + '\n')
			return

	client_info[clntnm] = {
		'server': srv,
		'time difference': lag,
		'time command received': time_received,
		'latitude': latt,
		'longitude': lon
	}

	await propagate(clntnm)


async def propagate(clntnm):
	client = client_info[clntnm]
	my_at_command = 'AT %s %s %s %s %s %s' % (clntnm, client['server'], client['latitude'], client['longitude'], str(client['time difference']), str(client['time command received']))

	#print(str(client['time difference']), str(client['time command received']))

	for cnnctn in connection_dict[srv]:
		port = ports[cnnctn]
		#print('propagating ' + clntnm + ' to ' + cnnctn)
		await output_log('propagating ' + clntnm + ' to ' + cnnctn)
		
		try:
			rdr, wrtr = await asyncio.open_connection('127.0.0.1', port, loop=loop)
			await output_log('connected successfully\n')
			#print('connected successfully')
			await send_resp(wrtr, my_at_command)
			await output_log('closed connection to ' + cnnctn + '\n')
		
		except:
			#print('failed to send message to ' + cnnctn)
			await output_log('failed to send message to ' + cnnctn)


async def get_cmd(wrtr, cmd, token):
	if len(token) > 0:
		command_0 = token[0]

		if (cmd != '' and command_0 != 'IAMAT' and command_0 != 'WHATSAT' and command_0 != 'AT'):
			await output_log('command ' + cmd + 'is invalid\n')
			await output_log('? ' + cmd + '\n')
			#print('command ' + cmd + ' is invalid')
			print('? ' + cmd)
			await send_resp(wrtr, '? ' + cmd)
			return None 

		if len(token) > 3:
			await output_log('received command:' + cmd + '\n')
			#print('received command:' + cmd)

		curr_time = time.time()
		log_message = 'type: ' + command_0 + '. time received: ' + str(curr_time)
		#print(log_message)
		await output_log(log_message + '\n')

		if command_0 == 'IAMAT':
			try:
				await handle_iamat(token[1], token[2], token[3], curr_time, wrtr)
			except:
				await output_log('invalid command' + cmd + '\n')
				print('? ' + cmd)
				await send_resp(wrtr, '? ' + cmd)
		elif command_0 == 'WHATSAT':
			try:
				await handle_whatsat(token[1], token[2], token[3], curr_time, cmd, wrtr)
			except:
				await output_log('invalid command' + cmd + '\n')
				print('? ' + cmd)
				await send_resp(wrtr, '? ' + cmd)
		elif command_0 == 'AT':
			#print(token)
			try:
				await handle_at(token[1], token[2], token[3], token[4], token[5], token[6], wrtr)
			except:
				await output_log('invalid command' + cmd + '\n')
				print('? ' + cmd)
				await send_resp(wrtr, '? ' + cmd)
		else:
			await output_log('invalid command' + cmd + '\n')
			print('? ' + cmd)
			await send_resp(wrtr, '? ' + cmd)

	else: 
		await output_log('invalid command' + cmd + '\n')
		print('? ' + cmd)
		await send_resp(wrtr, '? ' + cmd)

def get_cl(rdr, wrtr):
	async def get_cl_h(rdr, wrtr):
		while True:
			if rdr.at_eof():
				break
			p0 = await rdr.read()
			p1 = p0.decode()
			p2 = p1.split()
			await get_cmd(wrtr, p1, p2)

	item = asyncio.ensure_future(get_cl_h(rdr, wrtr))
	all_items_dict[item] = (rdr, wrtr)

	def end_session(item):
		#print('client is closed')
		server_log.write('client is closed\n')
		#print(client_info)
		del all_items_dict[item]
		wrtr.close()
    
	item.add_done_callback(end_session)

def main():
	num_args = len(sys.argv)
	if num_args != 2:
		print("incorrect number of arguments")
		exit()

	global srv
	srv = sys.argv[1]

	if srv not in ports:
		print("incorrect name of server")
		exit()

	global server_log
	server_log = open(srv + "-log.txt", 'w+')

	global loop
	loop = asyncio.get_event_loop()

	#print("using server " + srv)
	server_log.write("using server " + srv + '\n')

	acc_cntn = asyncio.start_server(get_cl, '127.0.0.1', ports[srv], loop=loop)
	svr = loop.run_until_complete(acc_cntn)

	#print("host: " + '127.0.0.1\t' + "port: " + str(ports[srv]))
	server_log.write("host: " + '127.0.0.1\t' + "port: " + str(ports[srv]) + '\n\n')
	
	try:
		loop.run_forever()
	except KeyboardInterrupt:
		pass
	
	#print('\nserver closed\ttime:', time.time())
	server_log.write('\nserver closed\ttime:' + str(time.time()))
	svr.close()
	loop.run_until_complete(svr.wait_closed())
	loop.close()
	server_log.close()

if __name__ == '__main__':
    main()
