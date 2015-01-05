#!/usr/bin/env perl
=pod
=head1 Usage
To migrate all users from Drupal => Mediawiki do the following
=over 4
=item Run this script.
=item Visit L<URL/wiki/Spezial:Benutzer_importieren> and import the generated mw_users.csv file.
=item Run this script again.
=cut

use v5.12;
use strict;
use DBI;
no warnings 'experimental::smartmatch';
my $dbiUrl = 'mysql:database=offenebibel1;host=localhost;port=3306';
my $dbUser = "root";
my $dbPassword = "test1234";

my $dbh = DBI->connect('dbi:'.$dbiUrl,$dbUser,$dbPassword)
    or die "Connection Error: $DBI::errstr\n";

my %drupalUsers;
my $rows = $dbh->selectall_arrayref(
# Select both, users with roles and users without.
    'SELECT
        bibeldrupalusers.name AS username,
        bibeldrupalusers.pass,
        bibeldrupalusers.mail,
        bibeldrupalrole.name AS rolename
    FROM bibeldrupalusers
    RIGHT JOIN bibeldrupalusers_roles ON bibeldrupalusers.uid = bibeldrupalusers_roles.uid
    LEFT JOIN bibeldrupalrole ON bibeldrupalusers_roles.rid = bibeldrupalrole.rid
    UNION
    SELECT
        bibeldrupalusers.name AS username,
        bibeldrupalusers.pass,
        bibeldrupalusers.mail,
    NULL AS rolename
    FROM bibeldrupalusers
    LEFT JOIN bibeldrupalusers_roles ON bibeldrupalusers.uid = bibeldrupalusers_roles.uid
    WHERE
        bibeldrupalusers_roles.uid IS NULL
    ', { Slice => {} });
foreach my $row (@$rows) {
    next if not $row->{mail} =~ m/@/;
#    say "$row->{username}: $row->{pass}, $row->{mail}, $row->{rolename}";
    if(not defined $drupalUsers{$row->{username}}) {
        $drupalUsers{$row->{username}} = {
            "username" => $row->{username},
            "password" => $row->{pass},
            "email" => $row->{mail},
        };
    }
    if(not defined $drupalUsers{$row->{username}}->{roles}) {
        $drupalUsers{$row->{username}}->{roles} = [];
    }

    if(defined $row->{rolename}) {
        push @{$drupalUsers{$row->{username}}->{roles}}, $row->{rolename};
    }
}

my %mwUsers;
foreach my $row (
@{$dbh->selectall_arrayref(
'SELECT user_id, user_email, ug_group
FROM bibelwikiuser LEFT JOIN bibelwikiuser_groups ON bibelwikiuser.user_id = bibelwikiuser_groups.ug_user
WHERE ug_group IS NULL
UNION
SELECT user_id, user_email, ug_group
FROM bibelwikiuser RIGHT JOIN bibelwikiuser_groups ON bibelwikiuser.user_id = bibelwikiuser_groups.ug_user
',
{ Slice => {} })}
) {
    if(not defined $mwUsers{$row->{user_email}}) {
        $mwUsers{$row->{user_email}} = {
            "email" => $row->{user_email},
            "id" => $row->{user_id}
        };
    }
    if(not defined $mwUsers{$row->{user_email}}->{roles}) {
        $mwUsers{$row->{user_email}}->{roles} = [];
    }
    if(defined $row->{ug_group}) {
        push @{$mwUsers{$row->{user_email}}->{roles}}, $row->{ug_group};
    }
}

use Data::Dumper;
print Dumper(\%drupalUsers);
print Dumper(\%mwUsers);


my $userUpdateStmt = $dbh->prepare(
    'UPDATE bibelwikiuser SET user_password=? WHERE user_id = ?'
);
my $groupInsertStmt = $dbh->prepare(
    'INSERT INTO bibelwikiuser_groups VALUES (?, ?)'
);
my $groupDeleteStmt = $dbh->prepare(
    'DELETE FROM bibelwikiuser_groups WHERE ug_user = ? AND ug_group = ?'
);

open my $newUserFile, ">:utf8", "mw_users.csv";

foreach my $drupalUser (keys %drupalUsers) {
    my $dUser = $drupalUsers{$drupalUser};
    if(defined $mwUsers{$dUser->{email}}) {
        my $mwUser = $mwUsers{$dUser->{email}};
        # user is in MW

        # set password
            $userUpdateStmt->bind_param(1, ":A:" . $dUser->{password});
            $userUpdateStmt->bind_param(2, $mwUser->{id});
            $userUpdateStmt->execute;
            my @mwRoles = @{$mwUser->{roles}};
            my @dRoles = @{$dUser->{roles}};
        # - insert all missing groups
            foreach my $role (@dRoles) {
                # Trim to 16, since there is only space for 16 places in the
                # MW user_group table thus we need to trim to 16 to compare.
                if(not substr($role, 0, 16) ~~ @mwRoles) {
                    $groupInsertStmt->bind_param(1, $mwUser->{id});
                    $groupInsertStmt->bind_param(2, $role);
                    $groupInsertStmt->execute;
                }
            }
        # - remove all unnecessary groups
            foreach my $role (@mwRoles) {
                if(not $role ~~ @dRoles) {
                    $groupDeleteStmt->bind_param(1, $mwUser->{id});
                    $groupDeleteStmt->bind_param(1, $role);
                    $groupDeleteStmt->execute;
                }
            }
    }
    else {
        # user is *not* in MW -> create user
        # https://github.com/kghbln/ImportUsers/blob/master/ImportUsers_body.php

        print $newUserFile "$dUser->{username},dummypassword,$dUser->{email},$dUser->{username}\n";
    }
}

close $newUserFile;

