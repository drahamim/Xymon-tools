#!/bin/bash
function isnum() {
a=$1
echo "a is $a"
#[ ! -z "${a##[0-9]*}" ] && a=U
[ ! -z "${a}" ] && a=U
echo "a is $a"
[ -z "$a" ] && a=U
echo $a
}

#a=`isnum 1234`
#echo $a
var="123456a.fdsf"
echo ${var##[0-9]*.}
