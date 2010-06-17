#!/usr/bin/env python

import itertools, logging, select, socket
from common import *

class Player(object):
	def __init__(self, opensock, entity):
		self.somsgbuf = SocketMessageBuffer(opensock)
		self.entity = entity
	def fileno(self):
		return self.somsgbuf.fileno()

def main():
	logging.basicConfig(level=logging.DEBUG)
	servsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	servsock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
	servsock.bind(('', 7172))
	servsock.listen(socket.SOMAXCONN)
	players = []
	entidgen = itertools.count(1)
	while True:
		socksout = []
		socksin = [servsock]
		for plyr in players:
			if plyr.somsgbuf.pending_out():
				socksout.append(plyr)
			socksin.append(plyr)
		readyfds = select.select(socksin, socksout, [])
		for readrdy in readyfds[0]:
			if readrdy == servsock:
				logging.debug("Incoming connection")
				newsock, remaddr = servsock.accept()
				logging.info("Accepted connection from %s", remaddr)
				newplyr = Player(newsock, Entity(id=entidgen.next()))
				newplyr.somsgbuf.post_message("loggedin", id=newplyr.entity.id)
				players.append(newplyr)
				for plyr in players:
					newplyr.somsgbuf.post_message("entity", entity=plyr.entity)
					if plyr != newplyr:
						plyr.somsgbuf.post_message("entity", entity=newplyr.entity)
			else:
				try:
					readrdy.somsgbuf.receive_more()
				except SocketClosed:
					logging.info("Disconnected %s", readrdy.somsgbuf.get_socket().getpeername())
					players.remove(readrdy)
					for plyr in players:
						plyr.somsgbuf.post_message("remove_entity", id=readrdy.entity.id)
				else:
					message = readrdy.somsgbuf.get_message()
					if message is not None:
						logging.debug("Received message: %s", message)
						if message.title == "move":
							newpos = readrdy.entity.coords
							newpos += DIRECTIONS[message.kwdata["direction"]]
							print newpos
							if	newpos.x in xrange(VIEWPORT_DIMENSIONS[0]) \
									and newpos.y in xrange(VIEWPORT_DIMENSIONS[1]):
								readrdy.entity.coords = newpos
								for plyr in players:
									plyr.somsgbuf.post_message("entity", entity=readrdy.entity)
						elif message.title == "say":
							fullmsg = "{0}: {1}".format(readrdy.entity.id, message.pdata[0])
							for plyr in players:
								plyr.somsgbuf.post_message("chat", fullmsg)
		for writerdy in readyfds[1]:
			writerdy.somsgbuf.send_pending()

if __name__ == "__main__":
	main()

		#self.servsock = create_server()
		#self.clentids = [] # connected client ids
		#self.entities = {}
		#self.entidgen = itertools.count(1)
		#while True:
			#pendoutl = filter(lambda a: a.pending_out(), self.iter_clients())
			#ready = select.select([self.servsock] + self.iter_clients(), pendoutl, [])
			#for r in ready[0]:
				#if r == self.servsock:
					#logging.debug("Incoming connection")
					#newsock, remaddr = self.servsock.accept()
					#logging.info("Accepted connection from %s" % str(remaddr))
					#self.add_client(newsock, remaddr)
				#else:
					#try:
						#r.recv()
					#except Disconnected:
						#self.remove_client(r)
			#for w in ready[1]:
				#w.send()
			#self.handle_player_messages()
			#if self.changed:
				#self.send_entity_info()
				#self.changed = False


#import itertools
#import logging
#import pdb
#import random
#import select
#import socket

#from common import *

#def create_server():
	#servsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
	#servsock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
	#servsock.bind(('', 7172))
	#servsock.listen(socket.SOMAXCONN)
	#return servsock

#class Client(Entity, SocketMessageBuffer):
	#def __init__(self, clntsock, addr, entid):
		#Entity.__init__(self,
				#entid=entid,
				#coords=Coords(random.randrange(15), random.randrange(11)),
				#color=tuple([random.randrange(i) for i in (0x100,) * 3]))
		#SocketMessageBuffer.__init__(self, clntsock)
		#self.post_message('loggedin', coords=self.get_coords(), color=self.get_color())
	#def entity_repr(self):
		#return Entity.__repr__(self)

#class Server(object):
	#def remove_client(self, client):
		#self.clients.remove(client)
	#def process_message(self, client, title, data):
		#if title == 'move':
			##pdb.set_trace()
			#newpos = client.get_coords() + DIRECTIONS[data['direction']]
			#if newpos.x in range(15) and newpos.y in range(11):
				#client.set_coords(newpos)
			#client.post_message('moved', coords=client.get_coords())
	#def handle_player_messages(self):
		#for client in self.iter_clients():
			#while True:
				#msg = client.get_message()
				#if msg is not None:
					#logging.debug("Received message: %s" % str(msg))
					#self.process_message(client, *msg)
					#self.changed = True
				#else:
					#break
	#def iter_clients(self):
		#return map(lambda x: self.entities[x], self.clentids)

	#def send_entity_info(self):
		#for client in self.iter_clients():
			#for entity in self.entities.itervalues():
				#client.post_message('entity', eval=repr(entity))

	#def add_client(self, clntsock, remaddr):
		#client = Client(clntsock, remaddr, self.entidgen.next())
		#clientid = client.get_entity_id()
		#self.clentids.append(clientid)
		#assert clientid not in self.entities
		#self.entities[clientid] = client
		#self.changed = True

	#def remove_client(self, client):
		#logging.info("Disconnected: %s" % str(client.get_socket().getpeername()))
		#clientid = client.get_entity_id()
		#self.clentids.remove(clientid)
		#del self.entities[clientid]

	#def __call__(self):
		#self.servsock = create_server()
		#self.clentids = [] # connected client ids
		#self.entities = {}
		#self.entidgen = itertools.count(1)
		#while True:
			#pendoutl = filter(lambda a: a.pending_out(), self.iter_clients())
			#ready = select.select([self.servsock] + self.iter_clients(), pendoutl, [])
			#for r in ready[0]:
				#if r == self.servsock:
					#logging.debug("Incoming connection")
					#newsock, remaddr = self.servsock.accept()
					#logging.info("Accepted connection from %s" % str(remaddr))
					#self.add_client(newsock, remaddr)
				#else:
					#try:
						#r.recv()
					#except Disconnected:
						#self.remove_client(r)
			#for w in ready[1]:
				#w.send()
			#self.handle_player_messages()
			#if self.changed:
				#self.send_entity_info()
				#self.changed = False

#def main():
	#logging.basicConfig(level=logging.DEBUG)
	#Server()()

#if __name__ == "__main__":
	#main()
