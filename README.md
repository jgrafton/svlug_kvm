Using QEMU & Kernel Virtual Machine (KVM) on CentOS 7
=====================================================


### introduction
"KVM (Kernel Virtual Machine) is a Linux kernel module that allows a user space program to utilize the hardware virtualization features of various processors.  Today, it supports recent Intel and AMD processors (x86 and x86_64), PPC 440, PPC 970, S/390, ARM (Cortex A15), and MIPS32 processors.

QEMU can make use of KVM when running a target architecture that is the same as the host architecture. For instance, when running qemu-system-x86 on an x86 compatible processor, you can take advantage of the KVM acceleration - giving you benefit for your host and your guest system." - from wiki.qemu.org

### What exactly are QEMU, KVM, and libvirt?

QEMU provides the environment for emulating a computer, such as virtual disks,
network interfaces, a video console, etc.

KVM is the software that does the actual magic of virtualization by
communicating with CPU

libvirt is the glue that binds it all together.  It provides the API to create,
destroy, and manage virtual machines.

### kvm / qemu installation
Debian and Ubuntu are my preferred workstation Linux distro's and RHEL / CentOS
for server distro's.

## CentOS
    sudo yum install kvm virt-manager libvirt virt-install qemu-kvm xauth dejavu-lgc-sans-fonts

## Ubuntu
    sudo apt-get install cpu-checker qemu-kvm libvirt-bin virt-manager

### networking

Bridged networking vs Isolated network

Setup a host bridge on your primary interface and copy the IP address from your
primary interface to the new bridge interface.

The script create_bridge.sh in this repository will do this for you
automatically in CentOS Linux.


### security

If you want your local user to have permissions to create and destroy VMs, add
the user to the kvm local group and add the policy kit file
(80-libvirt-manage.rules) in this repository
to /etc/polkit-1/rules.d/


### links
* \[1\] [Ubuntu Libvirt Documentation](https://help.ubuntu.com/lts/serverguide/libvirt.html)
* \[2\] [Install and use CentOS 7 or RHEL 7 as KVM virtualization host](http://jensd.be/?p=207)
* \[3\] [Differences between KVM and QEMU - ServerFault](http://serverfault.com/questions/208693/difference-between-kvm-and-qemu)

