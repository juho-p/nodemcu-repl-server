#!/bin/sh

for a in $*; do
    curl -i --data-binary @$a http://192.168.4.1/upload/$a
done
