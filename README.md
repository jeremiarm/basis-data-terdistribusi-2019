# ETS BDT 2019

# 1. Desain dan Implementasi Infrastruktur

## DESAIN INFRASTRUKTUR

### Gambar Infrastruktur
![alt text](https://github.com/jeremiarm/basis-data-terdistribusi-2019/blob/master/Desain%20Infrastruktur/Desain%20Infrastruktur.png)

### Jumlah Server <br />
->Server Database sebanyak 3 buah <br />
->Proxy sebanya 1 buah <br />
->Apache web server sebanyak 1 buah <br />
### Spesifikasi Hardware <br />
Database MySQL Server masing-masing RAM 1024 MB dengan OS bento/ubuntu-16.04 <br />
Proxy MySQL dengan RAM 1024 MB dengan OS bento/ubuntu-16.04 <br />
Apache Webserver  dengan RAM 8192 MB dengan OS Windows 8.1 Pro <br />
### Pembagian IP <br />
192.168.16.102 (MySQL Server 1) <br />
192.168.16.103 (MySQL Server 2) <br />
192.168.16.104 (MySQL Server 3) <br />
192.168.16.105 (Proxy MySQL) <br />
localhost (Apache WebServer) <br />

## IMPLEMENTASI INFRASTRUKTUR

### Proses Instalasi

1. Install aplikasi :
    - Vagrant 2.25
    - Virtual Box
2. Jalankan perintah dibawah untuk membuat file ``VagrantFile``
``` 
Vagrant Init 
```
3. Modifikasi file ``VagrantFile`` menjadi sebagai berikut
```
# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.

Vagrant.configure("2") do |config|
  
  # MySQL Cluster dengan 3 node
  (1..3).each do |i|
    config.vm.define "db#{i}" do |node|
      node.vm.hostname = "db#{i}"
      node.vm.box = "bento/ubuntu-16.04"
      node.vm.network "private_network", ip: "192.168.16.#{i+101}"

      # Opsional. Edit sesuai dengan nama network adapter di komputer
      #node.vm.network "public_network", bridge: "Qualcomm Atheros QCA9377 Wireless Network Adapter"
      
      node.vm.provider "virtualbox" do |vb|
        vb.name = "db#{i}"
        vb.gui = false
        vb.memory = "1024"
      end
  
      node.vm.provision "shell", path: "sh/deployMySQL1#{i}.sh", privileged: false
    end
  end

  config.vm.define "proxy" do |proxy|
    proxy.vm.hostname = "proxy"
    proxy.vm.box = "bento/ubuntu-16.04"
    proxy.vm.network "private_network", ip: "192.168.16.105"
    #proxy.vm.network "public_network",  bridge: "Qualcomm Atheros QCA9377 Wireless Network Adapter"
    
    proxy.vm.provider "virtualbox" do |vb|
      vb.name = "proxy"
      vb.gui = false
      vb.memory = "1024"
    end

    proxy.vm.provision "shell", path: "sh/deployProxySQL.sh", privileged: false
  end

end
```
Penjelasan code : VagrantFile akan membentuk 3 server database dengan IP 192.168.16.102 s.d 192.168.16.104 dengan nama db1, db2, db3 dan memori 1024 MB OS bento/ubuntu-16.04 , dengan masing-masing scriptnya dengan path sh/deployMySQL1i . Kemudian akan membentuk server proxyMySQL dengan ip 192.168.16.105 dengan memori 1024, nama proxy dan OS bento/ubuntu-16.04. Script proxtMySQL ada di path sh/deployProxySQL.sh

4. Membuat script provision untuk db1, db2, db3, proxy
-Script Provision db1
```
# Changing the APT sources.list to kambing.ui.ac.id
sudo cp '/vagrant/sources.list' '/etc/apt/sources.list'

# Updating the repo with the new sources
sudo apt-get update -y

# Install required library
sudo apt-get install libaio1
sudo apt-get install libmecab2

# Get MySQL binaries
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-common_5.7.23-1ubuntu16.04_amd64.deb
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-client_5.7.23-1ubuntu16.04_amd64.deb
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-client_5.7.23-1ubuntu16.04_amd64.deb
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-server_5.7.23-1ubuntu16.04_amd64.deb

# Setting input for installation
sudo debconf-set-selections <<< 'mysql-community-server mysql-community-server/root-pass password admin'
sudo debconf-set-selections <<< 'mysql-community-server mysql-community-server/re-root-pass password admin'

# Install MySQL Community Server
sudo dpkg -i mysql-common_5.7.23-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-community-client_5.7.23-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-client_5.7.23-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-community-server_5.7.23-1ubuntu16.04_amd64.deb

# Allow port on firewall
sudo ufw allow 33061
sudo ufw allow 3306

# Copy MySQL configurations
sudo cp /vagrant/cnf/my11.cnf /etc/mysql/my.cnf

# Restart MySQL services
sudo service mysql restart

# Cluster bootstrapping
sudo mysql -u root -padmin < /vagrant/sql/cluster_bootstrap.sql
sudo mysql -u root -padmin < /vagrant/sql/addition_to_sys.sql
sudo mysql -u root -padmin < /vagrant/sql/create_proxysql_user.sql
```
-Script Provision db2
```
# Changing the APT sources.list to kambing.ui.ac.id
sudo cp '/vagrant/sources.list' '/etc/apt/sources.list'

# Updating the repo with the new sources
sudo apt-get update -y

# Install required library
sudo apt-get install libaio1
sudo apt-get install libmecab2

# Get MySQL binaries
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-common_5.7.23-1ubuntu16.04_amd64.deb
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-client_5.7.23-1ubuntu16.04_amd64.deb
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-client_5.7.23-1ubuntu16.04_amd64.deb
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-server_5.7.23-1ubuntu16.04_amd64.deb

# Setting input for installation
sudo debconf-set-selections <<< 'mysql-community-server mysql-community-server/root-pass password admin'
sudo debconf-set-selections <<< 'mysql-community-server mysql-community-server/re-root-pass password admin'

# Install MySQL Community Server
sudo dpkg -i mysql-common_5.7.23-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-community-client_5.7.23-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-client_5.7.23-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-community-server_5.7.23-1ubuntu16.04_amd64.deb

# Allow port on firewall
sudo ufw allow 33061
sudo ufw allow 3306

# Copy MySQL configurations
sudo cp /vagrant/cnf/my12.cnf /etc/mysql/my.cnf

# Restart MySQL services
sudo service mysql restart

# Cluster bootstrapping
sudo mysql -u root -padmin < /vagrant/sql/cluster_member.sql
```
-Script Provision db3
```
# Changing the APT sources.list to kambing.ui.ac.id
sudo cp '/vagrant/sources.list' '/etc/apt/sources.list'

# Updating the repo with the new sources
sudo apt-get update -y

# Install required library
sudo apt-get install libaio1
sudo apt-get install libmecab2

# Get MySQL binaries
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-common_5.7.23-1ubuntu16.04_amd64.deb
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-client_5.7.23-1ubuntu16.04_amd64.deb
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-client_5.7.23-1ubuntu16.04_amd64.deb
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-server_5.7.23-1ubuntu16.04_amd64.deb

# Setting input for installation
sudo debconf-set-selections <<< 'mysql-community-server mysql-community-server/root-pass password admin'
sudo debconf-set-selections <<< 'mysql-community-server mysql-community-server/re-root-pass password admin'

# Install MySQL Community Server
sudo dpkg -i mysql-common_5.7.23-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-community-client_5.7.23-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-client_5.7.23-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-community-server_5.7.23-1ubuntu16.04_amd64.deb

# Allow port on firewall
sudo ufw allow 33061
sudo ufw allow 3306

# Copy MySQL configurations
sudo cp /vagrant/cnf/my13.cnf /etc/mysql/my.cnf

# Restart MySQL services
sudo service mysql restart

# Cluster bootstrapping
sudo mysql -u root -padmin < /vagrant/sql/cluster_member.sql
```
-Script Provision proxy
```
# Changing the APT sources.list to kambing.ui.ac.id
sudo cp '/vagrant/sources.list' '/etc/apt/sources.list'

# Updating the repo with the new sources
sudo apt-get update -y

cd /tmp
curl -OL https://github.com/sysown/proxysql/releases/download/v1.4.4/proxysql_1.4.4-ubuntu16_amd64.deb
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-common_5.7.23-1ubuntu16.04_amd64.deb
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-community-client_5.7.23-1ubuntu16.04_amd64.deb
curl -OL https://dev.mysql.com/get/Downloads/MySQL-5.7/mysql-client_5.7.23-1ubuntu16.04_amd64.deb

sudo apt-get install libaio1
sudo apt-get install libmecab2

sudo dpkg -i proxysql_1.4.4-ubuntu16_amd64.deb
sudo dpkg -i mysql-common_5.7.23-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-community-client_5.7.23-1ubuntu16.04_amd64.deb
sudo dpkg -i mysql-client_5.7.23-1ubuntu16.04_amd64.deb

sudo ufw allow 33061
sudo ufw allow 3306

sudo systemctl start proxysql
#mysql -u admin -p -h 127.0.0.1 -P 6032 < /vagrant/sql/proxysql.sql
#password : admin 
#password : password
```
Penjelasan script provision db1,db2,db3,proxy ada di comment dari source code.

5. Membuat file script sql pendukung script provision, yaitu:
- ``addition_to_sys.sql`` yaitu patch script untuk ProxyMySQL 
```
USE sys;

DELIMITER $$

CREATE FUNCTION IFZERO(a INT, b INT)
RETURNS INT
DETERMINISTIC
RETURN IF(a = 0, b, a)$$

CREATE FUNCTION LOCATE2(needle TEXT(10000), haystack TEXT(10000), offset INT)
RETURNS INT
DETERMINISTIC
RETURN IFZERO(LOCATE(needle, haystack, offset), LENGTH(haystack) + 1)$$

CREATE FUNCTION GTID_NORMALIZE(g TEXT(10000))
RETURNS TEXT(10000)
DETERMINISTIC
RETURN GTID_SUBTRACT(g, '')$$

CREATE FUNCTION GTID_COUNT(gtid_set TEXT(10000))
RETURNS INT
DETERMINISTIC
BEGIN
  DECLARE result BIGINT DEFAULT 0;
  DECLARE colon_pos INT;
  DECLARE next_dash_pos INT;
  DECLARE next_colon_pos INT;
  DECLARE next_comma_pos INT;
  SET gtid_set = GTID_NORMALIZE(gtid_set);
  SET colon_pos = LOCATE2(':', gtid_set, 1);
  WHILE colon_pos != LENGTH(gtid_set) + 1 DO
     SET next_dash_pos = LOCATE2('-', gtid_set, colon_pos + 1);
     SET next_colon_pos = LOCATE2(':', gtid_set, colon_pos + 1);
     SET next_comma_pos = LOCATE2(',', gtid_set, colon_pos + 1);
     IF next_dash_pos < next_colon_pos AND next_dash_pos < next_comma_pos THEN
       SET result = result +
         SUBSTR(gtid_set, next_dash_pos + 1,
                LEAST(next_colon_pos, next_comma_pos) - (next_dash_pos + 1)) -
         SUBSTR(gtid_set, colon_pos + 1, next_dash_pos - (colon_pos + 1)) + 1;
     ELSE
       SET result = result + 1;
     END IF;
     SET colon_pos = next_colon_pos;
  END WHILE;
  RETURN result;
END$$

CREATE FUNCTION gr_applier_queue_length()
RETURNS INT
DETERMINISTIC
BEGIN
  RETURN (SELECT sys.gtid_count( GTID_SUBTRACT( (SELECT
Received_transaction_set FROM performance_schema.replication_connection_status
WHERE Channel_name = 'group_replication_applier' ), (SELECT
@@global.GTID_EXECUTED) )));
END$$

CREATE FUNCTION gr_member_in_primary_partition()
RETURNS VARCHAR(3)
DETERMINISTIC
BEGIN
  RETURN (SELECT IF( MEMBER_STATE='ONLINE' AND ((SELECT COUNT(*) FROM
performance_schema.replication_group_members WHERE MEMBER_STATE != 'ONLINE') >=
((SELECT COUNT(*) FROM performance_schema.replication_group_members)/2) = 0),
'YES', 'NO' ) FROM performance_schema.replication_group_members JOIN
performance_schema.replication_group_member_stats USING(member_id));
END$$

CREATE VIEW gr_member_routing_candidate_status AS SELECT
sys.gr_member_in_primary_partition() as viable_candidate,
IF( (SELECT (SELECT GROUP_CONCAT(variable_value) FROM
performance_schema.global_variables WHERE variable_name IN ('read_only',
'super_read_only')) != 'OFF,OFF'), 'YES', 'NO') as read_only,
sys.gr_applier_queue_length() as transactions_behind, Count_Transactions_in_queue as 'transactions_to_cert' from performance_schema.replication_group_member_stats;$$

DELIMITER ;
```
- ``cluster_bootstrap.sql`` yaitu script untuk melakukan bootstrapping MySQL group replication (hanya dilakukan pada salah satu db server saja, pada tugas ini digunakan pada db1) dan membuat database yang akan digunakan

```
SET SQL_LOG_BIN=0;
CREATE USER 'repl'@'%' IDENTIFIED BY 'password' REQUIRE SSL;
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
SET SQL_LOG_BIN=1;
CHANGE MASTER TO MASTER_USER='repl', MASTER_PASSWORD='password' FOR CHANNEL 'group_replication_recovery';
INSTALL PLUGIN group_replication SONAME 'group_replication.so';

SET GLOBAL group_replication_bootstrap_group=ON;
START GROUP_REPLICATION;
SET GLOBAL group_replication_bootstrap_group=OFF;

CREATE DATABASE meetingroom;
```

- ``cluster_member.sql`` yaitu script untuk untuk melakukan konfigurasi MySQL group replication pada node db yang lain.
```
SET SQL_LOG_BIN=0;
CREATE USER 'repl'@'%' IDENTIFIED BY 'password' REQUIRE SSL;
GRANT REPLICATION SLAVE ON *.* TO 'repl'@'%';
FLUSH PRIVILEGES;
SET SQL_LOG_BIN=1;
CHANGE MASTER TO MASTER_USER='repl', MASTER_PASSWORD='password' FOR CHANNEL 'group_replication_recovery';
INSTALL PLUGIN group_replication SONAME 'group_replication.so';
```

- ``create_proxysql_user.sql`` yaitu script untuk membuat user pada proxysql( monitor untuk monitoring dan mradmin untuk aplikasi)

```
CREATE USER 'monitor'@'%' IDENTIFIED BY 'monitorpassword';
GRANT SELECT on sys.* to 'monitor'@'%';
FLUSH PRIVILEGES;

CREATE USER 'mradmin'@'%' IDENTIFIED BY 'mradmin';
GRANT ALL PRIVILEGES on meetingroom.* to 'mradmin'@'%';
FLUSH PRIVILEGES;
```

- ``proxysql.sql`` yaitu script untuk pengaturan proxy pada server proxysql

```
UPDATE global_variables SET variable_value='admin:password' WHERE variable_name='admin-admin_credentials';
LOAD ADMIN VARIABLES TO RUNTIME;
SAVE ADMIN VARIABLES TO DISK;

UPDATE global_variables SET variable_value='monitor' WHERE variable_name='mysql-monitor_username';
LOAD MYSQL VARIABLES TO RUNTIME;
SAVE MYSQL VARIABLES TO DISK;

INSERT INTO mysql_group_replication_hostgroups (writer_hostgroup, backup_writer_hostgroup, reader_hostgroup, offline_hostgroup, active, max_writers, writer_is_also_reader, max_transactions_behind) VALUES (2, 4, 3, 1, 1, 3, 1, 100);

INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (2, '192.168.16.102', 3306);
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (2, '192.168.16.103', 3306);
INSERT INTO mysql_servers(hostgroup_id, hostname, port) VALUES (2, '192.168.16.104', 3306);

LOAD MYSQL SERVERS TO RUNTIME;
SAVE MYSQL SERVERS TO DISK;

INSERT INTO mysql_users(username, password, default_hostgroup) VALUES ('mradmin', 'mradmin', 2);
LOAD MYSQL USERS TO RUNTIME;
SAVE MYSQL USERS TO DISK;
```

6. Membuat file konfigurasi server database (.cnf)
- File konfigurasi db1 (my11.cnf)
```
#
# The MySQL database server configuration file.
#
# You can copy this to one of:
# - "/etc/mysql/my.cnf" to set global options,
# - "~/.my.cnf" to set user-specific options.
# 
# One can use all long options that the program supports.
# Run program with --help to get a list of available options and with
# --print-defaults to see which it would actually understand and use.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

#
# * IMPORTANT: Additional settings that can override those from this file!
#   The files must end with '.cnf', otherwise they'll be ignored.
#

!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/

[mysqld]

# General replication settings
gtid_mode = ON
enforce_gtid_consistency = ON
master_info_repository = TABLE
relay_log_info_repository = TABLE
binlog_checksum = NONE
log_slave_updates = ON
log_bin = binlog
binlog_format = ROW
transaction_write_set_extraction = XXHASH64
loose-group_replication_bootstrap_group = OFF
loose-group_replication_start_on_boot = ON
loose-group_replication_ssl_mode = REQUIRED
loose-group_replication_recovery_use_ssl = 1

# Shared replication group configuration
loose-group_replication_group_name = "3ebc8b09-3b03-41e8-9010-4ac1cdb09306"
loose-group_replication_ip_whitelist = "192.168.16.102, 192.168.16.103, 192.168.16.104"
loose-group_replication_group_seeds = "192.168.16.102:33061, 192.168.16.103:33061, 192.168.16.104:33061"

# Single or Multi-primary mode? Uncomment these two lines
# for multi-primary mode, where any host can accept writes
loose-group_replication_single_primary_mode = OFF
loose-group_replication_enforce_update_everywhere_checks = ON

# Host specific replication configuration
server_id = 1
bind-address = "192.168.16.102"
report_host = "192.168.16.102"
loose-group_replication_local_address = "192.168.16.102:33061"
```
-File konfigurasi db2(my12.cnf)
```
#
# The MySQL database server configuration file.
#
# You can copy this to one of:
# - "/etc/mysql/my.cnf" to set global options,
# - "~/.my.cnf" to set user-specific options.
# 
# One can use all long options that the program supports.
# Run program with --help to get a list of available options and with
# --print-defaults to see which it would actually understand and use.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

#
# * IMPORTANT: Additional settings that can override those from this file!
#   The files must end with '.cnf', otherwise they'll be ignored.
#

!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/

[mysqld]

# General replication settings
gtid_mode = ON
enforce_gtid_consistency = ON
master_info_repository = TABLE
relay_log_info_repository = TABLE
binlog_checksum = NONE
log_slave_updates = ON
log_bin = binlog
binlog_format = ROW
transaction_write_set_extraction = XXHASH64
loose-group_replication_bootstrap_group = OFF
loose-group_replication_start_on_boot = ON
loose-group_replication_ssl_mode = REQUIRED
loose-group_replication_recovery_use_ssl = 1

# Shared replication group configuration
loose-group_replication_group_name = "3ebc8b09-3b03-41e8-9010-4ac1cdb09306"
loose-group_replication_ip_whitelist = "192.168.16.102, 192.168.16.103, 192.168.16.104"
loose-group_replication_group_seeds = "192.168.16.102:33061, 192.168.16.103:33061, 192.168.16.104:33061"

# Single or Multi-primary mode? Uncomment these two lines
# for multi-primary mode, where any host can accept writes
loose-group_replication_single_primary_mode = OFF
loose-group_replication_enforce_update_everywhere_checks = ON

# Host specific replication configuration
server_id = 2
bind-address = "192.168.16.103"
report_host = "192.168.16.103"
loose-group_replication_local_address = "192.168.16.103:33061"
```
-File konfigurasi db3(my13.cnf)
```
#
# The MySQL database server configuration file.
#
# You can copy this to one of:
# - "/etc/mysql/my.cnf" to set global options,
# - "~/.my.cnf" to set user-specific options.
# 
# One can use all long options that the program supports.
# Run program with --help to get a list of available options and with
# --print-defaults to see which it would actually understand and use.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

#
# * IMPORTANT: Additional settings that can override those from this file!
#   The files must end with '.cnf', otherwise they'll be ignored.
#

!includedir /etc/mysql/conf.d/
!includedir /etc/mysql/mysql.conf.d/

[mysqld]

# General replication settings
gtid_mode = ON
enforce_gtid_consistency = ON
master_info_repository = TABLE
relay_log_info_repository = TABLE
binlog_checksum = NONE
log_slave_updates = ON
log_bin = binlog
binlog_format = ROW
transaction_write_set_extraction = XXHASH64
loose-group_replication_bootstrap_group = OFF
loose-group_replication_start_on_boot = ON
loose-group_replication_ssl_mode = REQUIRED
loose-group_replication_recovery_use_ssl = 1

# Shared replication group configuration
loose-group_replication_group_name = "3ebc8b09-3b03-41e8-9010-4ac1cdb09306"
loose-group_replication_ip_whitelist = "192.168.16.102, 192.168.16.103, 192.168.16.104"
loose-group_replication_group_seeds = "192.168.16.102:33061, 192.168.16.103:33061, 192.168.16.104:33061"

# Single or Multi-primary mode? Uncomment these two lines
# for multi-primary mode, where any host can accept writes
loose-group_replication_single_primary_mode = OFF
loose-group_replication_enforce_update_everywhere_checks = ON

# Host specific replication configuration
server_id = 3
bind-address = "192.168.16.104"
report_host = "192.168.16.104"
loose-group_replication_local_address = "192.168.16.104:33061"
```

Penjelasan code :
-gtid= ON
-Memberikan loose-group_replication_group_name universal unique ID (UUID). UUID bisa didapat dari UUID generator online.
-Memberikan loose-group_replication_ip_whitelist list IP pada group replication
-Memberikan loose-group_replication_group_seeds list IP dan port pada group replication
-loose-group_replication_single_primary_mode = OFF
-loose-group_replication_enforce_update_everywhere_checks =ON
-Memberikan server_id , bind-address, report_host, loose-group_replication_local_address IP dan port sesuai server masing-masing.

7. Menjalankan vagrant
- Buka cmd di lokasi ``VagrantFile`` berada, kemudian jalankan ``vagrant up``. Proses ini berjalan cukup lama, butuh koneksi internet dan space memory yang cukup
- jalankan ``vagrant status`` untuk mengecek apakah setiap server yang dikonfigurasikan berjalan
- jalankan ``vagrant ssh proxy`` untuk masuk ke server proxysql
- jalankan ``mysql -u admin -p -h 127.0.0.1 -P 6032 < /vagrant/sql/proxysql.sql`` (password = admin) untuk menjalankan script proxysql.sql (setelah dijalankan, password akan berubah jadi "password)
- jalankan mysql -u admin -p -h 127.0.0.1 -P 6032 --prompt='ProxySQLAdmin> '
- jalankan SELECT hostgroup_id, hostname, status FROM runtime_mysql_servers; untuk mengecek server yang tergroup
