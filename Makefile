CCGO = gccgo

all:
	@make release
release:
	make client
	make server
debug:
	make client_debug
	make server_debug
client_debug:
	@go build -gcflags "-N -l" -o dtunnel_d client.go
server_debug:
	@go build -gcflags "-N -l" -o dtunnel_s_d server.go
client:
	@go build -ldflags "-s -w" -o dtunnel client.go
server:
	@go build -ldflags "-s -w" -o dtunnel_s server.go
gccgo:
	mkdir tmp -p
	$(CCGO) ikcp/ikcp.go ikcp/ikcp_h.go -c -o tmp/ikcp.o
	$(CCGO) common/common.go common/cache.go -c -o tmp/common.o
	$(CCGO) nat/stun/stun.go -c -o tmp/stun.o
	cp connection_gccgo.go tmp/connection.go
	cp nat/gather.go tmp/
	cp nat/nat.go tmp/
	cp client.go tmp/
	cd tmp/ && $(CCGO) connection.go -c && $(CCGO) gather.go -c && $(CCGO) nat.go gather.go connection.go -c
	cd tmp/ && $(CCGO) client.go -c && $(CCGO) -o dtunnel_gccgo client.o nat.o ikcp.o common.o stun.o -static-libgo
	cp tmp/dtunnel_gccgo ./
clean:
	@rm -rf dtunnel dtunnel_d dtunnel_s_d dtunnel_s dtunnel_gccgo tmp/
.PHONY: all debug release client_debug server_debug client server clean
