#!/bin/bash

n=1
while :; do
	head -c $n </dev/urandom >in.bin;
	./tp0 -a encode -i in.bin -o out.b64;
	base64 in.bin > out-ref.b64;
	if diff -b out.b64 out-ref.b64; then :; else
		echo ERROR encoding: $n;
		break;
	fi
	
	./tp0 -a decode -i out.b64 -o out.bin;
	if diff in.bin out.bin; then :; else
		echo ERROR decoding: $n;
		break;
	fi
	echo ok: $n;
	n="`expr $n + 1`";
	rm -f in.bin out.b64 out.bin out-ref.b64;
done
	
