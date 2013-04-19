%define name mpt-status
%define version 1.2.0
%define release RH4

Name:      mpt-status
Summary:   LSI Logic RAID controller status utility
Version:   %{version}
Release:   %{release}
Source:    %{name}-%{version}.tar.gz
License:   GPL
Vendor:    OpenSource
Group:     System Environment/Base

%description

Mpt-status is a utility for monitoring LSI Logic RAID controllers. The
utility utilizes the LSI logic mptctl device driver, which is provided
with most modern Linux distributions. To use mpt-status to view the
health of an LSI Logic RAID controller, mpt-status can be run without
any options:

$ mpt-status
ioc0 vol_id 0 type IM, 2 phy, 136 GB, state OPTIMAL, flags ENABLED
ioc0 phy 0 scsi_id 0 SEAGATE  ST3146707LC      D704, 136 GB, state ONLINE, flags NONE
ioc0 phy 1 scsi_id 1 SEAGATE  ST3146707LC      D704, 136 GB, state ONLINE, flags NONE

To view the RAID controller status in a parseable format, mpt-status
can be run with the "-s" option:

$ mpt-status -s
log_id 0 OPTIMAL
phys_id 0 ONLINE
phys_id 1 ONLINE

If you encounter the following error when running mpt-status:

$ /usr/sbin/mpt-status
open /dev/mptctl: No such file or directory
  Try: mknod /dev/mptctl c 10 220
Make sure mptctl is loaded into the kernel

You will need to ensure that a line similar to the following exists in
/etc/modules.conf:

alias char-major-10-220 mptctl

And the mptctl driver is loaded in the kernel:

$ /sbin/lsmod | grep mptctl
mptctl                 35397  0 
mptbase                61345  5 mptctl,mptsas,mptspi,mptfc,mptscsi

If the driver is not present, the modprobe utility can be used
to load it:

$ /sbin/modprobe mpctl

Happy mpt-status'ing!

%prep

%setup

%build 

TEMP=$(mktemp /tmp/Makefile.XXXXXX)
sed 's/\(INSTALL.*install\)\(.*\)/\1/g' Makefile > ${TEMP}
mv ${TEMP} Makefile
make

%install

make install

cp man/mpt-status.8 /usr/share/man/man8

%files
%defattr(-,root,root)

/usr/sbin/mpt-status
/usr/share/man/man8/mpt-status.8

%post

# Check to see if an LSI Logic controller is present
if ! grep LSI /proc/scsi/mptspi/* > /dev/null
then
    echo "** Unable to locate a LSI Logic controller in /proc/scsi/mptspi/*"
    echo "** This may prevent you from using the mpt-status utility"
    echo ""
fi

# Load the mptctl kernel module at boot
if ! grep "char-major-10-220" /etc/modules.conf > /dev/null
then
    echo "** Adding mptctl driver information to /etc/modules.conf"
    echo "alias char-major-10-220 mptctl" >> /etc/modules.conf
    echo ""
fi

