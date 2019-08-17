#!/bin/bash
#run as super user
#unbind port 80
#check if port 80 is binded
#lsof -i tcp:80
ruby wshell.rb -o 0.0.0.0
