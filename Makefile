mcufiles := $(wildcard *.lua *.html *.js)
luatool := luatool/luatool.py --baud 9600 --port /dev/ttyUSB0 --src
baseurl = http://192.168.4.1

# --------

syncfiles := $(addprefix .upload/, $(addsuffix .t, $(mcufiles)))

sync: $(syncfiles)
	curl -i -X POST -d'node.restart()' $(baseurl)/eval
	@echo ''

clean:
	rm -rv .upload

.upload/%.t: %
	@mkdir -p .upload
	curl -i --data-binary @$< $(baseurl)/upload/$< && touch $@

initial_setup:
	$(luatool) replserver.lua
	$(luatool) conn_util.lua
	$(luatool) http_util.lua
	$(luatool) util.lua
	echo 'dofile "replserver.lua"' > tmpinit.lua
	echo 'start_server(function() end)' >> tmpinit.lua
	$(luatool) tmpinit.lua --dest init.lua -r
	rm tmpinit.lua
