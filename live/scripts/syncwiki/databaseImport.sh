#!/bin/bash

# Initializing parameters
# Usage ./databaseImport.sh username password database wikicode oaipass
user=$1
pass=$2
db=$3
dumpPath="$HOME/workspace/dump/$4wiki/$4wiki-latest"
oaiPass=$5
mwdPath="$HOME/workspace/tools"
wikiPath="/var/www/wiki"


echo   "Creating database $db"
mysql -u $user -p$pass -e "create database if not exists $db"
mysql -u $user -p$pass -e "show databases"

echo   "Loading tables.sql file into database $db"
mysql -u $user -p$pass $db < "$wikiPath/maintenance/tables.sql"
mysql -u $user -p$pass -e "use $db; show tables"

# Performance imporvement for mysql bulk loading
mysql -u $user -p$pass $db -e "SET GLOBAL autocommit=0;SET GLOBAL unique_checks=0;SET GLOBAL foreign_key_checks=0;"
echo   "Loading pages-articles.xml file into databse $db, this will take a while" 

#java -jar "$mwdPath/mwdumper.jar" --format=sql:1.5 "$dumpPath-pages-articles.xml" | mysql -u $user -p$pass -f --default-character-set=utf8 $db

echo   "Loading imagelinks.sql file into $db"
mysql -u $user -p$pass $db < "$dumpPath-imagelinks.sql"
echo   "Loading image.sql file into $db"
mysql -u $user -p$pass $db < "$dumpPath-image.sql"
echo   "Loading langlinks.sql file into $db"
mysql -u $user -p$pass $db < "$dumpPath-langlinks.sql"
echo   "Loading templatelinks.sql file into $db \n"
mysql -u $user -p$pass $db < "$dumpPath-templatelinks.sql"

echo   "Loading update_table.sql file into $db \n"

# Loading update_table.sql in 2 pieces, first the table crate statement and then the insert
# otherwise it will give an error

mysql -u $user -p$pass $db <  sed -n '6,20p' "$wikiPath/extensions/OAI/update_table.sql"
mysql -u $user -p$pass $db <  sed -n '33,37p' "$wikiPath/extensions/OAI/update_table.sql"
echo   "Loading oaiuser_table.sql file into $db \n"
mysql -u $user -p$pass $db < "$wikiPath/extensions/OAI/oaiuser_table.sql"
echo   "Loading oaiharvest_table.sql file into $db \n"
mysql -u $user -p$pass $db < "$wikiPath/extensions/OAI/oaiharvest_table.sql"
echo   "Loading oaiaudit_table.sql file into $db \n"
mysql -u $user -p$pass $db < "$wikiPath/extensions/OAI/oaiaudit_table.sql"
echo "INSERT INTO /*$wgDBprefix*/oaiuser(ou_name, ou_password_hash) VALUES ('dbpedia', md5('$oaiPass') );" | mysql $db -u $user -p$pass

# Bulk load is finished, so we reset the mysql global variables to their defaults
mysql -u $user -p$pass $db -e "SET GLOBAL autocommit=1;SET GLOBAL unique_checks=1;SET GLOBAL foreign_key_checks=1;"






