ls -la /
rpm -qa --qf '%{name}-%{version}-%{release}.%{arch}\n'
cat /etc/redhat-release
cat /etc/sysctl.d/98-oracle.conf
cat /etc/security/limits.d/99-grid-oracle-limits.conf
cat /etc/selinux/config
cat /etc/sysconfig/grub
cat /etc/fstab
cat /etc/sysconfig/network
cat /etc/systemd/logind.conf
cat /home/grid/.bash_profile
cat /home/oracle/.bash_profile
