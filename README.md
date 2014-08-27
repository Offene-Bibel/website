Development Setup
=================

1. Download and extract the website snapshot. It should contain:
    - drupal
    - mediawiki
    - static
    - mysqldump.bin
    - README.md (this file)
2. Install MySQL and start it.
3. Import the database dump: `mysql ...`
4. Install a webserver (e.g. apache) and serve the following directories:
    - drupal
    - mediawiki
    - static
5. Change the following files to match your database and webserver:
    - `drupal/asdf`:123
    - `mediawiki/asdf`:123
6. Clone drupal and mediawiki extension repositories.
        
        git clone git@gitorious.org:offene-bibel/drupal7-skin.git drupal
        git clone git@gitorious.org:offene-bibel/mediawiki-extension.git mediawiki

7. Set up converter (according to README.md)
    - `git clone git@gitorious.org:offene-bibel/offene-bibel-converter.git offene-bibel-converter`
    - Install a Java 7
    - Install maven2
    - run `build.sh`
8. Set up validator
    - `git clone git@gitorious.org:offene-bibel/validator-webservice.git validator-webservice`
    - Set converter path in `validator-webservice/asdf`:123
    - Activate local mode in `validator-webservice/asdf`:123
    - Set up database access in `validator-webservice/asdf`:123
