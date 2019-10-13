# ETS BDT 2019

# 1. Desain dan Implementasi Infrastruktur

## DESAIN INFRASTRUKTUR

### Gambar Infrastruktur
<br />
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

1. Aplikasi yang harus diinstall
    - Vagrant
