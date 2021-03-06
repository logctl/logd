#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IN="$DIR/reload_eof.in"
SCRIPT="$DIR/reload_eof.lua"
OUT="$DIR/reload_eof.out"
ERR="$DIR/reload_eof.err"
LOGD_EXEC="$DIR/../bin/logd"
PID=
WRITER_PID=0
WRITER_PID2=0

source $DIR/helper.sh

function finish {
	CODE=$?
	rm -f $SCRIPT
	rm -f $OUT
	rm -f $ERR
	rm -f $IN
	kill $PID
	if [ $WRITER_PID2 -ne 0 ]; then
		kill $WRITER_PID2
	fi
	exit $CODE;
}

trap finish EXIT

function makescript() {
	truncate -s 0 $SCRIPT
	cat >$SCRIPT << EOF
local logd = require("logd")
function logd.on_log(logptr)
	io.write("log")
	io.flush()
end
EOF
}

function makewriter() {
	while sleep 1; do :; done >$IN &
}

function makepipe() {
	mkfifo $IN 2> /dev/null 1> /dev/null
	makewriter
}

function pushdata() {
	cat >$IN << EOF
2018-05-12 12:51:28 ERROR	[thread1]	clazz	a: A, 
2018-05-12 12:52:22 WARN	[thread2]	clazz	callType: b: B
EOF
}

touch $OUT
makepipe
WRITER_PID=$!
makescript
$LOGD_EXEC $SCRIPT --reopen-retries=10 --reopen-delay=10 --reopen-backoff=lineal -f $IN 2> $ERR 1> $OUT & 
PID=$!
sleep $TESTS_SLEEP

pushdata
assert_file_content "loglog" $OUT

# kill writer to force EOF
kill $WRITER_PID
makewriter
WRITER_PID2=$!

pushdata
assert_file_content "loglogloglog" $OUT

exit 0
