Development Setup
=================

1. Download and extract the website snapshot. It should contain:
    - drupal
    - mediawiki
    - static
    - mysqldump.bin
    - README.md (this file)
2. Install DB and PHP.

    - install

            # ubuntu
            apt-get install apache2 mysql-server php5 php5-mysql
            # redhat
            yum install httpd mariadb-server mariadb php php-mysqlnd

    - Start DB and apache

            # redhat
            systemctl start httpd.service
            systemctl start mariadb.service

    - Optionally start DB and apache on system start
    
            # redhat
            systemctl enable httpd.service
            systemctl enable mariadb.service

3. Set up database user.

    mysql -uroot
    create database offenebibel1 character set utf8 collate utf8_general_ci;
    create user offenebibel identified by 'put_password_here';
    # the following grants access to the table from everywhere, shouldn''t do that
    #grant ALL privileges on offenebibel1.* to offenebibel@'%' identified by 'put_password_here';
    grant ALL privileges on offenebibel1.* to offenebibel@localhost identified by 'put_password_here';
    quit

4. Import the database dump.

    mysql -uoffenebibel -p -hlocalhost --default-character-set=utf8 offenebibel1 <mysqldump_20140902.bin

5. Adapt apache to serve the `website` directory. `scripts/apache.conf` is a configuration snippet that should pretty much get you there.
6. Adapt `drupal/sites/default/settings.php` and `mediawiki/LocalSettings.php` to match your database and webserver.
7. You might need to reload the apache configuration. `systemctl reload httpd.service` or `/etc/init.d/httpd reload`.
8. Try it. In a Browser open <http://localhost:1111/startseite>.

9. Update the git repository or do a fresh clone.

    git pull # update
    rm -rf .git && git clone git@gitorious.org:offene-bibel/website.git # fresh clone


If you want to set up the syntax validator too, there are some more steps to do:

10. Clone and set up the converter.
    - cd somewhere you want the converter to reside
    - `git clone git@gitorious.org:offene-bibel/offene-bibel-converter.git`
    - Follow the `README.md`
11. Clone and set up the validator.
    - `git clone git@gitorious.org:offene-bibel/validator-webservice.git`
    - Follow the `README.md`

