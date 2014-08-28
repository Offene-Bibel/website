#!/usr/bin/perl
use v5.12;
use strict;

use Getopt::Long;
use POSIX qw(strftime);
use File::Slurp;
use FindBin;

my $drupalSrcFolder = "/kunden/248589_32760/webseiten/ptesting";
my $wikiSrcFolder = "/kunden/248589_32760/webseiten/wtesting/wiki";
my $outputFolder = "$FindBin::Bin/..";
my $outputFile = "snapshot-" . strftime("%Y-%m-%d", localtime) . ".tgz";
my $dbUser = "db248589_7";
my $dbName = "db248589_7";
my $dbHost = "mysql5.offene-bibel.de";

GetOptions ("source:s" => \$webFolder,
            "file:s" => \$outputFile,
            "user:s" => \$dbUser,
            "name:s" => \$dbName,
            "host:s" => \$dbHost,
            )
            or die("Error in command line arguments\n");

die "Output file already exists" if -e $outputFile;

print "Enter the DB password: ";
my $dbPassword = <STDIN>; chomp $dbPassword;


print 'Creating database dump... ';
    print `mysqldump -u$dbUser -p$dbPassword -h$dbHost $dbName -r$outputFolder/mysqldump.bin`;
say 'done';

print 'Copying drupal... ';
    print `rm -r $outputFolder/drupal`;
    print `cp -r $drupalSrcFolder $outputFolder/drupal`;
say 'done';

print 'Copying mediawiki... ';
    print `rm -r $outputFolder/mediawiki`;
    print `cp -r $mediawikiSrcFolder $outputFolder/mediawiki`;
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
            if m/^(.*)\/\/<<&REPLACEMENT&>>(.*)$/ {
                print "$2//<<&REPLACEMENT&>>$2";
            }

            s/$dbPassword/<&db_password&>/g;
            s/$dbName/<&db_name&>/g;
            s/$dbUser/<&db_user&>/g;
            s/$dbHost/<&db_host&>/g;
            s/$dbHost/<&db_host_port&>/g;
            print OUT; 
        }
        close OUT;
    }
say 'done';

print 'Zipping... ';
    print `tar -czf $outputFile $outputFolder`;
say 'done';

print 'Removing temporary files... ';
    print `chmod -R u+w $outputFolder`;
    print `rm -rf $outputFolder`;
say 'done';

say 'Finished.';

