CREATE USER 'monitor'@'%' IDENTIFIED BY 'monitorpassword';
GRANT SELECT on sys.* to 'monitor'@'%';
FLUSH PRIVILEGES;

CREATE USER 'mradmin'@'%' IDENTIFIED BY 'mradmin';
GRANT ALL PRIVILEGES on meetingroom.* to 'mradmin'@'%';
FLUSH PRIVILEGES;