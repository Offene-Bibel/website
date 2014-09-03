- install MySQL and PHP

    sudo apt-get install apache2 mysql-server php5 php5-mysql

- Create database

    mysql -uroot
    create database offenebibel1 character set utf8 collate utf8_general_ci;
    create user offenebibel identified by 'cgW3VWmrMg';
    grant ALL privileges on offenebibel1.* to offenebibel@'%' identified by 'cgW3VWmrMg';
    grant ALL privileges on offenebibel1.* to offenebibel@localhost identified by 'cgW3VWmrMg';
    quit

- Adapt `drupal/sites/default/settings.php` and `mediawiki/LocalSettings.php`
- Import the database dump

    mysql -uoffenebibel -p -hlocalhost --default-character-set=utf8 offenebibel1 <mysqldump_20140902.bin

- Try it. In a Browser open <http://localhost:1111/startseite>