print 'Checking out repository... ';
    print `git clone git://gitorious.org/offene-bibel/website.git $outputFolder`;
say 'done';

print 'Replacing database credentials... ';
    my @fileList = qw(
    mediawiki/LocalSettings.php
    drupal/sites/default/settings.php
    );

    for (@fileList) {
        my $file = "$outputFolder/$_";
        my @lines = read_file($file);
        chmod 0660, $file;
        open (OUT, ">", $file) or die $!;
        for (@lines) {
            s/<&db_host&>/$dbHost/g;
            s/<&db_port&>/$dbPort/g;
            s/<&db_db&>/$dbDb/g;
            s/<&db_user&>/$dbUser/g;
            s/<&db_password&>/$dbPassword/g;
            print OUT; 
        }
        close OUT;
    }
say 'done';

