#!/usr/bin/env perl
=pod
Script to add the tables needed for the syntax checker
and selector.
=cut

use v5.12;
use strict;
use utf8;

use DBI;

my $dbh = DBI->connect('dbi:'.$config->{dbi_url},$config->{dbi_user},$config->{dbi_pw})
    or die "Connection Error: $DBI::errstr\n";

$dbh->do(<<END);
CREATE TABLE `bibelwikiofbi_parse_errors` (
  `pageid` int(11) DEFAULT NULL,
  `revid` int(11) DEFAULT NULL,
  `error_occurred` tinyint(1) DEFAULT NULL,
  `error_string` mediumtext
);
END

$dbh->do(<<END);
CREATE TABLE `bibelwikiofbi_book` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `osis_name` varchar(10) NOT NULL,
  `name` varchar(45) NOT NULL,
  `chapters` int(11) NOT NULL,
  `part` varchar(2) NOT NULL,
  PRIMARY KEY (`id`)
);
END

$dbh->do(<<END);
CREATE TABLE `bibelwikiofbi_chapter` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `book_id` int(11) NOT NULL,
  `number` int(11) NOT NULL,
  `verses` int(11) NOT NULL,
  PRIMARY KEY (`id`)
);
END

$dbh->do(<<END);
CREATE TABLE `bibelwikiofbi_verse` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `chapter_id` int(11) NOT NULL,
  `page_id` int(10) NOT NULL,
  `rev_id` int(10) NOT NULL,
  `version` tinyint(1) NOT NULL,
  `from_number` int(11) NOT NULL,
  `to_number` int(11) NOT NULL,
  `status` tinyint(1) NOT NULL,
  `text` text NOT NULL,
  PRIMARY KEY (`id`)
);
END

for my $book (@books) {
    $dbh->do(<<END, {}, ($book->[0], $book->[1], $book->[2], $book->[3]));
INSERT INTO bibelwikiofbi_book VALUES (?, ?, ?, ?);
END
    my $book_id = $dbh->last_insert_id(undef, undef, undef, undef);

    my $insert_statement = $dbh->prepare(<<END);
INSERT INTO bibelwikiofbi_chapter VALUES (?, ?, ?);
END
    for my $chapter (0..$book->[2]) {
        $insert_statement->execute(($book_id, $chapter, 0));
    }
}

my @books = (
['Gen', 'Genesis', 50, 'ot'],
['Exod'', Exodus', 40, 'ot'],
['Lev'', Levitikus', 27, 'ot'],
['Num'', Numeri', 36, 'ot'],
['Deut'', Deuteronomium', 34, 'ot'],
['Josh'', Josua', 24, 'ot'],
['Judg'', Richter', 21, 'ot'],
['Ruth'', Rut', 4, 'ot'],
['1Sam', '1 Samuel', 31, 'ot'],
['2Sam', '2 Samuel', 24, 'ot'],
['1Kgs', '1 Könige', 22, 'ot'],
['2Kgs', '2 Könige', 25, 'ot'],
['1Chr', '1 Chronik', 29, 'ot'],
['2Chr', '2 Chronik', 36, 'ot'],
['Ezra', 'Esra', 10, 'ot'],
['Neh', 'Nehemia', 13, 'ot'],
['Esth', 'Ester', 10, 'ot'],
['Job', 'Ijob', 42, 'ot'],
['Ps', 'Psalm', 150, 'ot'],
['Prov', 'Sprichwörter', 31, 'ot'],
['Eccl', 'Kohelet', 12, 'ot'],
['Song', 'Hohelied', 8, 'ot'],
['Isa', 'Jesaja', 66, 'ot'],
['Jer', 'Jeremia', 52, 'ot'],
['Lam', 'Klagelieder', 5, 'ot'],
['Ezek', 'Ezechiel', 48, 'ot'],
['Dan', 'Daniel', 14, 'ot'],
['Hos', 'Hosea', 14, 'ot'],
['Joel', 'Joel', 4, 'ot'],
['Amos', 'Amos', 9, 'ot'],
['Obad', 'Obadja', 1, 'ot'],
['Jonah', 'Jona', 4, 'ot'],
['Mic', 'Micha', 7, 'ot'],
['Nah', 'Nahum', 3, 'ot'],
['Hab', 'Habakuk', 3, 'ot'],
['Zeph', 'Zefanja', 3, 'ot'],
['Hag', 'Haggai', 2, 'ot'],
['Zech', 'Sacharja', 14, 'ot'],
['Mal', 'Maleachi', 3, 'ot'],
['Matt', 'Matthäus', 28, 'nt'],
['Mark', 'Markus', 16, 'nt'],
['Luke', 'Lukas', 24, 'nt'],
['John', 'Johannes', 21, 'nt'],
['Acts', 'Apostelgeschichte', 28, 'nt'],
['Rom', 'Römer', 16, 'nt'],
['1Cor', '1 Korinther', 16, 'nt'],
['2Cor', '2 Korinther', 13, 'nt'],
['Gal', 'Galater', 6, 'nt'],
['Eph', 'Epheser', 6, 'nt'],
['Phil', 'Philipper', 4, 'nt'],
['Col', 'Kolosser', 4, 'nt'],
['1Thess', '1 Thessalonicher', 5, 'nt'],
['2Thess', '2 Thessalonicher', 3, 'nt'],
['1Tim', '1 Timotheus', 6, 'nt'],
['2Tim', '2 Timotheus', 4, 'nt'],
['Titus', 'Titus', 3, 'nt'],
['Phlm', 'Philemon', 1, 'nt'],
['Heb', 'Hebräer', 13, 'nt'],
['Jas', 'Jakobus', 5, 'nt'],
['1Pet', '1 Petrus', 5, 'nt'],
['2Pet', '2 Petrus', 3, 'nt'],
['1John', '1 Johannes', 5, 'nt'],
['2John', '2 Johannes', 1, 'nt'],
['3John', '3 Johannes', 1, 'nt'],
['Jude', 'Judas', 1, 'nt'],
['Rev', 'Offenbarung', 22, 'nt'],
['Bar', 'Baruch', 6, 'ap'],
['Jdt', 'Judit', 16, 'ap'],
['1Macc', '1 Makkabäer', 16, 'ap'],
['2Macc', '2 Makkabäer', 15, 'ap'],
['Sir', 'Jesus Sirach', 51, 'ap'],
['Tob', 'Tobit', 14, 'ap'],
['Wis', 'Weisheit', 19, 'ap'],
);

