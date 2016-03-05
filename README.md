nodemcu-repl-server
-------------------

This project is a simple http-based development environment for ESP8266 nodemcu
firmware written in Lua. It includes simple HTML&JS based read-eval-print-loop
(REPL) that can be used from web browser.

In addition to REPL, it includes easy way to create more web pages (see
`main.lua`).

Firmware
--------

Before doing anyting else, flash your device with latest firmware

https://github.com/nodemcu/nodemcu-firmware

Use develop-branch firmware. It works better.

Getting started
---------------

This section is written to work in typical Linux distribution.

By default, the makefile assumes that MCU usb-serial adapter is in device
`/dev/ttyUSB0` and has the IP-address 192.168.4.1. If this is not the case,
modify the first few lines of Makefile accordingly.

Before you start, make sure you have nodemcu firmware flashed in your device
and see that it works with serial terminal. Before trying any of the following
commands, disconnect the serial terminal from the device.

First, upload few required lua-scripts with following command:

    make initial_setup

This uses luatool to upload files to the device and restarts it. It takes
rather long time.

If you haven't already done so, connect to the device using WLAN.

After that, upload the rest of the files.

    make

This uses the http server functionality that the previous step uploaded to send
all the files to the device.

After that, try using your browser to go http://192.168.4.1/console

It should display console UI web page which should respond to any type lua
commands.

You can make changes to any of the lua, html and js -files and call `make`
again. This repuploads the changed files and restarts the server

Some basic web page
-------------------

The `main.lua` includes some simple web page for an example. You can see this
by going to http://192.168.4.1

It should be easy to add more web pages in similar fashion for whatever
purpose. You can use any functions in `http_util.lua` to make things easier.

Luatool
-------

The luatool folder includes luatool.py for easier setup. It can be used for
initial file upload.  See https://github.com/4refr0nt/luatool for more
information.

Licensing
---------

nodemcu-repl-server is licenced with MIT-license. Note that luatool that is
included in this repository is licensed with GPLv2.
