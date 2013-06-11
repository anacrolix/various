package main

import (
	"log"
	"net"
	"net/http"
	"time"
)

type onCloseNetConn struct {
	net.Conn
	onClose func()
}

func (me onCloseNetConn) Close() error {
	me.onClose()
	return me.Conn.Close()
}

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, req *http.Request) {
		//w.WriteHeader(202)
		w.Write([]byte("{}"))
	})
	go http.ListenAndServe("localhost:3000", nil)
	onClose := func() {
		log.Print("closed")
	}
	http.DefaultTransport = &http.Transport{
		Dial: func(network, addr string) (net.Conn, error) {
			conn, err := net.Dial(network, addr)
			if err != nil {
				return conn, err
			}
			log.Print("made conn")
			return onCloseNetConn{conn, onClose}, err
		},
	}
	time.Sleep(time.Second)
	resp, err := http.Get("http://localhost:3000")
	if err != nil {
		log.Fatal(err)
	}
	resp.Body.Close()
	time.Sleep(3 * time.Second)
}
