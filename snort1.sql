create database snort;
create database archive;
grant usage on snort.* to root@localhost;
grant usage on archive.* to root@localhost;
set password for root@localhost=PASSWORD('123456');
grant all privileges on snort.* to root@localhost;
grant all privileges on archive.* to root@localhost;
flush privileges;
exit
