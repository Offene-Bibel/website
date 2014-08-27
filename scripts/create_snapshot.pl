#!/usr/bin/perl
use v5.12;
use strict;

use Getopt::Long;
use POSIX qw(strftime);
use File::Slurp;

my $resourceFolder = "resources";
my $webFolder = "/kunden/248589_32760/webseiten/offene-bibel.de";
my $outputFolder = "snapshot-" . strftime("%Y-%m-%d", localtime);
my $outputFile = $outputFolder . ".tgz";
my $dbUser = "db248589_2";
my $dbName = "db248589_2";
my $dbHost = "mysql5.offene-bibel.de";

GetOptions ("source:s" => \$webFolder,
            "file:s" => \$outputFile,
            "user:s" => \$dbUser,
            "name:s" => \$dbName,
            "host:s" => \$dbHost,
            )
            or die("Error in command line arguments\n");

die "Output folder path already exists" if -e $outputFolder;
die "Output file already exists" if -e $outputFile;

mkdir $outputFolder;

print "Enter the DB password: ";
my $dbPassword = <STDIN>; chomp $dbPassword;


print 'Creating database dump... ';
    print `mysqldump -u$dbUser -p$dbPassword -h$dbHost $dbName -r$outputFolder/mysqldump.bin`;
say 'done';

print 'Copying drupal and mediawiki... ';
    my $drupalFolder = $outputFolder . "/drupal";
    print `cp -r $webFolder $drupalFolder`;
say 'done';

# copy mediawiki
print 'Moving mediawiki to separate folder... ';
    print `mv $drupalFolder/wiki $outputFolder/mediawiki`;
say 'done';

# copy supplementary files (documentation, helper scripts, ...)
print 'Copying supplementary files... ';
    print `cp $resourceFolder/* $outputFolder`;
say 'done';

print 'Replacing database credentials... ';
    my @fileList = qw(
    mediawiki/skins/OffeneBibel.php
    mediawiki/LocalSettings.php
    drupal/sites/all/themes/offenebibel/page.tpl.php
    drupal/sites/all/modules/mediawikiauth/mediawikiauth.module
    drupal/sites/all/modules/mediawikiauth/Mediawiki.module
    drupal/sites/default/settings.php
    );

    for (@fileList) {
        my $file = "$outputFolder/$_";
        my @lines = read_file($file);
        chmod 0660, $file;
        open (OUT, ">", $file) or die $!;
        for (@lines) {
            s/$dbPassword/<&db_password&>/g;
            s/$dbName/<&db_name_or_user&>/g;
            s/$dbHost/<&db_host&>/g;
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

