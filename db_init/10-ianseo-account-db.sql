-- Create the default ianseo database along with the ianseo default
-- user and password.
--
-- Given that the web server and database reside in different
-- containers and have their own unique IP address we'll open up the
-- ianseo user's database access to all IPs (@'%') so the web
-- container can access the database.  The remote IP access is further
-- restricted since the web server and database are on their own
-- docker network.

USE mysql;

CREATE DATABASE ianseo;
CREATE USER 'ianseo'@'%' IDENTIFIED BY 'ianseo';
-- CREATE USER 'ianseo'@'%' IDENTIFIED WITH mysql_native_password BY 'ianseo';
GRANT ALL PRIVILEGES ON ianseo.* TO 'ianseo'@'%';
FLUSH PRIVILEGES;
