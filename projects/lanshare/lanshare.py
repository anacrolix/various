#!/usr/bin/env python

__ver__ = "0.1.0"
__pname__ = "LanShare"
__author__ = "Matt Joiner <anacrolix@gmail.com>"

class Lanshare(object):

	def __init__(self):
		object.__init__(self)

		from optparse import OptionParser
		parser = OptionParser()
		parser.add_option("--no-gui", default=False, action="store_true",
				help="Don't load the GUI")
		parser.add_option("--secure", default=False, action="store_true",
				help="Require explicit TLS on command and data connections")
		parser.add_option("--port", default=1337, action="store", type="int",
				help="Set the LanShare FTP port")
		options, posargs = parser.parse_args()
		print options, posargs

		from config import Config
		config = Config()

		from pyftpdlib import ftpserver
		if options.secure:
			from pyftpdlib.contrib.handlers import TLS_FTPHandler as handler
			handler.tls_control_required = True
			handler.certfile = "wotevs.pem"
		else:
			handler = ftpserver.FTPHandler
		handler.banner = "LanShare {0} ready.".format(__ver__)
		from filesys import LanshareFS
		LanshareFS.shares = config.shares
		handler.abstracted_fs = LanshareFS
		authorizer = ftpserver.DummyAuthorizer()
		authorizer.add_anonymous("/")
		handler.authorizer = authorizer
		self.server = ftpserver.FTPServer(("", 1337), handler)
		self.config = config

	def __call__(self):
		self.server.serve_forever()

def main():
	Lanshare()()

if __name__ == "__main__":
	main()