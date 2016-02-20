#!/bin/sh

killall ntpd
ntpd -p s2m.time.edu.cn
