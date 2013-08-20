 #!/usr/bin/ksh

 #
 # PURPOSE
 # This is an very simple script/test, but extremely useful.
 # It detects ANY hardware failure in Sun SPARC systems by using the
 standard 'prtdiag' command.  Prtdiag exits with a value of
 # '1' if there is an hardware error, otherwise with an exit code of '0'.
 # This way, no model/platform specific (i.e. V240/V890/15K, etc.)
 customizations are required, as the output of 'prtdiag'
 # differs on most systems. It works fine on Fujitsu-Siemens systems too.
 #
 # Provided by: Wim Olivier, Senior Solaris/VERITAS Engineer, AL Indigo,
 Johannesburg, South Africa
 # sunhw

 # INSTALLATION
 # 1.    Copy the script to $XYMONHOME/ext/xymon-prtdiag.ksh
 # 2.    Add it to the $XYMONHOME/etc/clientlaunch.cfg file
 #

 TEMPFILE=/$XYMONTMP/prtdiag.OUTPUT.$$
 TEST=prtdiag
 COLOR="green"

 if [ "$XYMONHOME" = "" ]
 then
         echo "XYMONHOME is not set... exiting"
         exit 1
 fi

 if [ ! "$XYMONTMP" ]                     # GET DEFINITIONS IF NEEDED,
 should never happen...
 then
          # echo "*** LOADING XYMON SETTINGS ***"
         . $XYMONHOME/etc/xymonclient.cfg          # INCLUDE STANDARD
 DEFINITIONS
 fi

 # What is this doing?

 PANIC="1"       # GO RED AND PAGE AT THIS LEVEL

 PLATFORM=`uname -i`
 /usr/platform/$PLATFORM/sbin/prtdiag -v > $TEMPFILE
 RESULT=$?
 #echo $RESULT
         #
         # DETERMINE RED/YELLOW/GREEN
         #
 if [ "$RESULT" -ne 0 ]
 then
     COLOR="red"
 fi

 #
 # AT THIS POINT WE HAVE OUR RESULTS.  NOW WE HAVE TO SEND IT TO
 # THE XYMSRV TO BE DISPLAYED...

 #

 MACHINE=`uname -n`

 #
 # THE FIRST LINE IS STATUS INFORMATION... STRUCTURE IMPORANT!
 # THE REST IS FREE-FORM - WHATEVER YOU'D LIKE TO SEND...
 #
 LINE="status $MACHINE.$TEST $COLOR `date`
 `cat $TEMPFILE`"

 $RM -f $TEMPFILE

 # NOW USE THE XYMON COMMAND TO SEND THE DATA ACROSS
 $XYMON $XYMSRV "$LINE"                     # SEND IT TO XYMONSRV

