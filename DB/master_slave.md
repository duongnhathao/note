#master_server 

edit my.cnf 

    bind-address : 0.0.0.0
    server-id = 1
    log_bin = /var/log/mysql/mysql-bin.log
    sudo systemctl restart mysql
    binlog_do_db = database
    ** open port for sql 
mysql : 
    
    mysql 

    ///create user access remote for database 
    CREATE USER 'slave_user'@'ip_address' IDENTIFIED BY 'slavepass';
    GRANT REPLICATION SLAVE ON *.* TO 'slave_user'@'ip_address';
    FLUSH PRIVILEGES;

    //lock database for checking , after run command this database cannot edit 
    USE database;
    FLUSH TABLES WITH READ LOCK;
    SHOW MASTER STATUS; 
    *** file and position are importance, take note it for next setting in slave server

    //dump sql for next step - or using sql application to export 
    mysqldump -u root -p --opt database > database.sql

    //unlock database
    UNLOCK TABLES;
    QUIT;

#slave_server 

mysql:

    import file just dump from master server 

my.conf: 

    server-id               = 2 // importance
    relay-log               = /var/log/mysql/mysql-relay-bin.log
    log_bin                 = /var/log/mysql/mysql-bin.log
    binlog_do_db            = database
    sudo service mysql restart

mysql: 

    //setup account connect to master server 
    CHANGE MASTER TO MASTER_HOST='master_server',MASTER_USER='slave_user', MASTER_PASSWORD='slavepass', MASTER_LOG_FILE='(from SHOW MASTER STATUS)', MASTER_LOG_POS=(from SHOW MASTER STATUS); 
    
    START SLAVE;
    //if slave is running , use command 'STOP SLAVE;' first
    
    // check running :
    SHOW SLAVE STATUS\G

    //check for connection 
    SET GLOBAL SQL_SLAVE_SKIP_COUNTER = 1; SLAVE START;
