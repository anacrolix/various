CC = gcc
CFLAGS = -Wall -std=c99 -g
COMMON_OBJS = network.o error.o tcpmsg.o

all: server client

server: server.o $(COMMON_OBJS)
	$(CC) $(CFLAGS) -o server server.o $(COMMON_OBJS)

client: client.o $(COMMON_OBJS)
	$(CC) $(CFLAGS) -o client client.o $(COMMON_OBJS)

clean:
	rm -f *.o server client

$(COMMON_OBJS) client.o server.o: error.h
client.o server.o: tcpmsg.h
tcpmsg.o server.o client.o: network.h
