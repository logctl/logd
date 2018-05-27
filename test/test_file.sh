#!/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
IN="$DIR/file.in"
SCRIPT="$DIR/file.lua"
OUT="$DIR/file.out"
LOGD_EXEC="$DIR/../bin/logd"

source $DIR/helper.sh

function finish {
	CODE=$?
	rm -f $SCRIPT
	rm -f $IN
	rm -f $OUT
	exit $CODE;
}

trap finish EXIT

touch $OUT
touch $IN

cat >$IN << EOF
2018-05-12 12:51:28 ERROR	[thread1]	clazz	a: A, 
2018-05-12 12:52:22 WARN	[thread2]	clazz	callType: b: B
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, 
2018-05-12 12:54:22 DEBUG	[thread4]	clazz	callType: b: ,
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:51:28 ERROR	[thread1]	clazz	a: A, 
2018-05-12 12:52:22 WARN	[thread2]	clazz	callType: b: B
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, 
2018-05-12 12:54:22 DEBUG	[thread4]	clazz	callType: b: ,
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:51:28 ERROR	[thread1]	clazz	a: A, 
2018-05-12 12:52:22 WARN	[thread2]	clazz	callType: b: B
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, 
2018-05-12 12:54:22 DEBUG	[thread4]	clazz	callType: b: ,
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:51:28 ERROR	[thread1]	clazz	a: A, 
2018-05-12 12:51:28 ERROR	[thread1]	clazz	a: A, 
2018-05-12 12:52:22 WARN	[thread2]	clazz	callType: b: B
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, 
2018-05-12 12:54:22 DEBUG	[thread4]	clazz	callType: b: ,
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:51:28 ERROR	[thread1]	clazz	a: A, 
2018-05-12 12:52:22 WARN	[thread2]	clazz	callType: b: B
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, 
2018-05-12 12:54:22 DEBUG	[thread4]	clazz	callType: b: ,
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:52:22 WARN	[thread2]	clazz	callType: b: B
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, 
2018-05-12 12:54:22 DEBUG	[thread4]	clazz	callType: b: ,
2018-05-12 12:51:28 ERROR	[thread1]	clazz	a: A, 
2018-05-12 12:51:28 ERROR	[thread1]	clazz	a: A, 
2018-05-12 12:52:22 WARN	[thread2]	clazz	callType: b: B
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, 
2018-05-12 12:51:28 ERROR	[thread1]	clazz	a: A, 
2018-05-12 12:52:22 WARN	[thread2]	clazz	callType: b: B
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, 
2018-05-12 12:51:28 ERROR	[thread1]	clazz	a: A, 
2018-05-12 12:52:22 WARN	[thread2]	clazz	callType: b: B
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, 
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, 
2018-05-12 12:54:22 DEBUG	[thread4]	clazz	callType: b: ,
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:54:22 DEBUG	[thread4]	clazz	callType: b: ,
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:54:22 DEBUG	[thread4]	clazz	callType: b: ,
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:52:22 WARN	[thread2]	clazz	callType: b: B
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, 
2018-05-12 12:54:22 DEBUG	[thread4]	clazz	callType: b: ,
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:51:28 ERROR	[thread1]	clazz	a: A, 
2018-05-12 12:52:22 WARN	[thread2]	clazz	callType: b: B
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, 
2018-05-12 12:54:22 DEBUG	[thread4]	clazz	callType: b: ,
2018-05-12 12:51:28 ERROR	[thread1]	clazz	a: A, 
2018-05-12 12:52:22 WARN	[thread2]	clazz	callType: b: B
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, 
2018-05-12 12:54:22 DEBUG	[thread4]	clazz	callType: b: ,
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:53:22 INFO	[thread3]	clazz	callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, callType: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
2018-05-12 12:55:22 TRACE	[thread5]	clazz	callType: b: c: C, 
EOF

cat >$SCRIPT << EOF
local logd = require("logd")
local expected = 12
local counter = 0
function logd.on_log(logptr)
  local level = logd.log_get(logptr, "level")
  if level == "ERROR" then
	  counter = counter + 1
  end
end
function logd.on_eof()
	assert(counter == expected,
		string.format("expected counter to be %d but found %d", expected, counter))
end
EOF

# stdin
cat $IN | $LOGD_EXEC $SCRIPT 2> $OUT 1> $OUT
if [ $? -ne 0 ]; then
	cat $OUT
	echo "error processing file via stdin"
	exit 1
fi

# using -f flag
$LOGD_EXEC $SCRIPT -f $IN 2> $OUT 1> $OUT
if [ $? -ne 0 ]; then
	cat $OUT
	echo "error processing file via -f flag"
	exit 1
fi

exit 0