#!/usr/bin/env python
import os
import sys
import string
import re

dict={}
value=[]
def main():
    if len(sys.argv) < 2:
	sys.exit('Usage: %s file.yml' % sys.argv[0])

    count = 0
    value = []
    for line in open(sys.argv[1], 'r'):
#	print line.rstrip()
	matchObj = re.search(r'"(.*)"', line, re.M|re.I)
	if matchObj and count == 0:
#	    print "here is 1 " ,matchObj.group(1)
	    key=matchObj.group(1) 
	    continue
	elif matchObj and count != 0:
#	    print "here 2"
	    dict[key]=[]
	    for i in value:
		dict[key].append(i) 
	    count = 0
	    value=[]
	    key=matchObj.group(1) 
	    continue
	matchObj2 = re.search(r'- (.*)', line, re.M|re.I)
	if matchObj2:
#	    print "here is 3" ,matchObj2.group(1)
	    value.append(matchObj2.group(1))
	    count += 1
	    continue
    #end of file, sycn remaining
    dict[key]=[]
    for i in value:
	dict[key].append(i) 
    
	
	    
    fh=open(sys.argv[1]+'.tab','w')

    for key in dict:
	print key, "==>",dict[key]
	for value in dict[key]:
	    fh.write(key+'||'+value+'\n')

    fh.close()
	    
	
if __name__=='__main__':
    main()
