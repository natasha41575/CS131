import asyncio
import time

async def tcp_echo_client(message, loop):
	reader, writer = await asyncio.open_connection('127.0.0.1', 12275, loop=loop)
	#reader, writer = await asyncio.open_connection('127.0.0.1', 12277, loop=loop)
	print("Sending:", message)
	writer.write(message.encode())
	writer.write_eof()
	data = await reader.read(100000)
	print("Received:", data.decode())
	# writer.close()


def main():
	#message = "\t\t\t\t\t    \f\f\fIAMAT\v\v\v\v\v   \t\fkiwi.cs.ucla.edu -33.86705222+151.1957 {0}\f\r\f\f\t\t\r\n".format(time.time())
	
	#loop.run_until_complete(tcp_echo_client(message, loop))

	message = "IAMAT kiwi.cs.ucla.edu +34.068930-118.44512 {0}\n".format(time.time())
	loop = asyncio.get_event_loop()
	loop.run_until_complete(tcp_echo_client(message, loop))


	# message = "IAMAT other +34.0698-118.445127 {0}\n".format(time.time())
	# loop.run_until_complete(tcp_echo_client(message, loop))
	
	loop = asyncio.get_event_loop()
	message = "WHATSAT \n\nkiwi.cs.ucla.edu 50 10\n"
	loop.run_until_complete(tcp_echo_client(message, loop))
	loop.close()
	# message = "WHATSAT other 5 20\n"
	# loop.run_until_complete(tcp_echo_client(message, loop))

if __name__ == '__main__':
	main()
