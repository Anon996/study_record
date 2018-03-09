# ubuntu vmware issue

1.无法启动，查看/tmp的log，参考[http://mihamina.rktmb.org/2015/12/vmware-workstation-12-unable-to-load.html](http://mihamina.rktmb.org/2015/12/vmware-workstation-12-unable-to-load.html)

Using VMWare Workstation on ArchLinux, it suddenly refused to launch.when inspecting the logs, which BTW are in /tmp/vmware-<id>, I see:

```
2015-12-11T17:41:54.442+03:00| appLoader| I125: Log for appLoader pid=1727 version=12.0.1 build=build-3160714 option=Release
 2015-12-11T17:41:54.442+03:00| appLoader| I125: The process is 64-bit.
 2015-12-11T17:41:54.442+03:00| appLoader| I125: Host codepage=UTF-8 encoding=UTF-8
 2015-12-11T17:41:54.442+03:00| appLoader| I125: Host is unknown
 2015-12-11T17:41:54.448+03:00| appLoader| W115: HostinfoReadDistroFile: Cannot work with empty file.
 2015-12-11T17:41:54.448+03:00| appLoader| W115: HostinfoOSData: Error: no distro file found
 2015-12-11T17:41:54.448+03:00|
 appLoader| I125: Invocation: "/usr/lib/vmware/bin/vmware-modconfig 
--launcher=/usr/bin/vmware-modconfig --appname=VMware Workstation 
--icon=vmware-workstation"
 2015-12-11T17:41:54.448+03:00|
 appLoader| I125: Calling: "/usr/lib/vmware/bin/vmware-modconfig 
--launcher=/usr/bin/vmware-modconfig --appname=VMware Workstation 
--icon=vmware-workstation"
 2015-12-11T17:41:54.448+03:00| appLoader| I125: VMDEVEL not set.
 2015-12-11T17:41:54.449+03:00| appLoader| I125: VMWARE_SHIPPED_LIBS_LIST is not set.
 2015-12-11T17:41:54.449+03:00| appLoader| I125: VMWARE_SYSTEM_LIBS_LIST is not set.
 2015-12-11T17:41:54.449+03:00| appLoader| I125: VMWARE_USE_SHIPPED_LIBS is not set.
 2015-12-11T17:41:54.449+03:00| appLoader| I125: VMWARE_USE_SYSTEM_LIBS is not set.
 2015-12-11T17:41:54.449+03:00| appLoader| I125: Using configuration file /etc/vmware/config.
 2015-12-11T17:41:54.449+03:00| appLoader| I125: Using library directory:  /usr/lib/vmware.
 2015-12-11T17:41:54.450+03:00| appLoader| I125: Shipped glib version is 2.24
 2015-12-11T17:41:54.450+03:00| appLoader| I125: System glib version is 2.46
 2015-12-11T17:41:54.450+03:00| appLoader| I125: Using system version of glib.
 2015-12-11T17:41:54.450+03:00| appLoader| I125: Detected VMware library libvmware-modconfig.so.
...
2015-12-11T17:41:54.774+03:00| appLoader| I125: Loading shipped version of libvmwareui.so.2015-12-11T17:41:54.834+03:00|
 appLoader| W115: Unable to load libvmwareui.so from 
/usr/lib/vmware/lib/libvmwareui.so/libvmwareui.so: 
/usr/lib/vmware/lib/libvmwareui.so/libvmwareui.so: undefined symbol: 
ZN4Glib10spawn_syncERKSsRKNS11ArrayHandleISsNS17Container_Helpers10TypeTraitsISsEEEENS10SpawnFlagsERKN4sigc4slotIvNSA_3nilESC_SC_SC_SC_SC_SC_EEPSsSG_Pi2015-12-11T17:41:54.834+03:00|
 appLoader| W115: Unable to load dependencies for 
/usr/lib/vmware/lib/libvmware-modconfig.so/libvmware-modconfig.so2015-12-11T17:41:54.834+03:00| appLoader| W115: Unable to execute /usr/lib/vmware/bin/vmware-modconfig.

```

I made it work with: 

```
export VMWARE_USE_SHIPPED_LIBS=yes  vmware
```

2.

```
echo /usr/lib/vmware/lib/libglibmm-2.4.so.1 | sudo tee -a /etc/ld.so.conf.d/LD_LIBRARY_PATH.conf
```

3.驱动编译不过 

after kernel 4.4 (VMWare Workstation 12) need some changes in c code:

/usr/lib/vmware/modules/source

 

1) vmmon.tar

```
  - untar
  - change ./vmmon-only/linux/hostif.c
  - replace all:
  "get_user_pages" to "get_user_pages_remote"
  - tar and replace original
```

2) vmnet.tar

```
  - untar
  - change ./vmnet-only/userif.c
  - replace all:
  "get_user_pages" to "get_user_pages_remote"
  - tar and replace original
```

 4.

````
/usr/share/themes/Arc/gtk-2.0/main.rc:1090: error: unexpected identifier 'direction', expected character '}'
````

Successful compiled on FC23 FC24, FC25 (kernel 4.7)