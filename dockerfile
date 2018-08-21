FROM centos:centos7
MAINTAINER czpfreedom<czp940811@sina.com>

LABEL RUN docker run -it --privileged -v /sys/bus/pci/devices:/sys/bus/pci/devices -v /sys/kernel/mm/hugepages:/sys/kernel/mm/hugepages -v /sys/devices/system/node:/sys/devices/system/node -v /dev:/dev --name NAME -e NAME=NAME -e IMAGE=IMAGE IMAGE

####### SET ENVIRONMENT ##################
ENV PATH $PATH:/usr/local/snort/bin:/usr/local/mysql/bin
ENV RTE_SDK /home/dpdk=16.04
ENV RTE_TARGET=x86_64-native-linuxapp-gcc
########################################## 

######## BUILD SOMETHINF USEFUL ##########
RUN yum -y install wget vim gcc gcc-c++ epel-release libpcap* flex bison tcpdump make  git hwloc* luajit* openssl*  cmake automake
RUN yum -y install luajit luajit* tar ncurses* libtermcap*i libmysqlclient-dev autoconf libtool
##########################################



######## BUILD DPDK ######################
COPY dpdk-16.04 /home/dpdk-16.04
##########################################



######## BUILD DAQ #######################
COPY daq-2.2.1 /home/daq-2.2.1
WORKDIR /home/daq-2.2.1/
RUN ./configure --with-dpdk-includes=/home/dpdk-16.04/x86_64-native-linuxapp-gcc/include     --with-dpdk-libraries=/home/dpdk-16.04/x86_64-native-linuxapp-gcc/lib
RUN aclocal && autoconf && autoheader &&automake -a &&  make && make install -j 20
##########################################



######## BUILD CMAKE #####################
WORKDIR /home
RUN wget https://cmake.org/files/v3.10/cmake-3.10.2.tar.gz && tar -zxvf cmake-3.10.2.tar.gz
WORKDIR /home/cmake-3.10.2
RUN ./bootstrap && gmake -j 20 && make install -j 20
##########################################

######## BUILD LIBNET ####################
WORKDIR /home 
RUN git clone https://github.com/dugsong/libdnet.git 
WORKDIR /home/libdnet 
RUN ./configure --prefix=/usr/local && make && make install
##########################################

######## BUILD SNORT #####################
COPY snort3 /home/snort3
WORKDIR /home/snort3
RUN ./configure_cmake.sh --with-dnet-libraries=/usr/local/libdnet/lib  --with-dnet-includes=/usr/local/libdnet/include 
RUN rm -f /home/snort3/build/src/CMakeFiles/snort.dir/link.txt
COPY link.txt /home/snort3/build/src/CMakeFiles/snort.dir
COPY liblzma.so /usr/lib64
COPY libuuid.so /usr/lib64
ENV LD_LIBRARY_PATH /usr/local/lib
RUN  /sbin/ldconfig
WORKDIR /home/snort3/build
RUN cp /home/libdnet/include/dnet/sctp.h  /usr/local/include/dnet && mkdir /usr/local/libdnet && mkdir /usr/local/libdnet/lib && cp /usr/local/lib/libdnet.so /usr/local/libdnet/lib
RUN make -j 20 && make install -j 20
RUN echo "/usr/local/lib" >  /etc/ld.so.conf && rm -f /etc/profile
COPY profile /etc
###########################################


######## BUILD RULES #####################
COPY test_snort /home/test
##########################################

####### BUILD MYSQL ######################
WORKDIR /home
RUN wget http://dev.mysql.com/get/Downloads/MySQL-5.1/mysql-5.1.73.tar.gz && tar -zxvf mysql-5.1.73.tar.gz
WORKDIR ./mysql-5.1.73 
RUN ./configure --prefix=/usr/local/mysql && make -j 20 && make install
##########################################

####### CONFIG MYSQL #####################
RUN cp support-files/my-medium.cnf /etc/my.cnf  && cp support-files/mysql.server /etc/init.d/mysqld && chmod 755 /etc/init.d/mysqld && chkconfig --add mysqld
WORKDIR /usr/local/mysql
RUN mkdir var && echo  "/usr/local/mysql/lib/mysql" >> /etc/ld.so.conf && ldconfig && ./bin/mysql_install_db && chmod -R 777  /usr/local/mysql/var && adduser mysql
##########################################

####### BUILD BARNYARD2 ##################
RUN mkdir /home/snort_mysql
WORKDIR /home
RUN wget https://github.com/firnsy/barnyard2/archive/v2-1.13.tar.gz -O barnyard2-2-1.13.tar.gz && tar -zxvf barnyard2-2-1.13.tar.gz
WORKDIR ./barnyard2-2-1.13
RUN autoreconf -fvi -I ./m4
RUN ./configure --with-mysql --with-mysql-libraries=/usr/local/mysql/lib/mysql --with-mysql-includes=/usr/local/mysql/include/mysql
RUN make && make install &&  cp /home/barnyard2-2-1.13/schemas/create_mysql /usr/src && mkdir /var/log/barnyard2
COPY snort1.sql /home/snort_mysql 
COPY snort2.sql /home/snort_mysql
##########################################

####### CONFIG BARNYARD2 #################
WORKDIR /home/snort_mysql
RUN /etc/rc.d/init.d/mysqld start && mysql -u root  < snort1.sql && mysql -u root -p123456 <snort2.sql
##########################################

######## CMD #############################
WORKDIR /home/test
CMD source /etc/profile && /etc/rc.d/init.d/mysqld start && /bin/bash
##########################################
