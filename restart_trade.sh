#!/bin/sh
SERVER_PATH=$(cd "$(dirname "$0")"; pwd)
if [ -f "$SERVER_PATH/tmp/pids/unicorn.pid" ];then
  kill `cat $SERVER_PATH/tmp/pids/unicorn.pid`
fi

cd $SERVER_PATH

unicorn -c config/unicorn.rb -E development -D

