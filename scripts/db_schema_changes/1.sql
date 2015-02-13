/*
Script to add the tables needed for the syntax checker
and selector.
 */

CREATE TABLE `bibelwikiofbi_book` (
  `osis_name` varchar(10) NOT NULL,
  `name` varchar(45) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
);

CREATE TABLE `bibelwikiofbi_chapter` (
  `book_id` int(11) NOT NULL,
  `number` int(11) NOT NULL,
  `id` int(11) NOT NULL AUTO_INCREMENT,
  PRIMARY KEY (`id`)
);

CREATE TABLE `bibelwikiofbi_parse_errors` (
  `pageid` int(11) DEFAULT NULL,
  `revid` int(11) DEFAULT NULL,
  `error_occurred` tinyint(1) DEFAULT NULL,
  `error_string` mediumtext
);

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

