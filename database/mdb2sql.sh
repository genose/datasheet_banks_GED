#!/bin/sh


if [ $# -ne 3 ]; then
echo "usage: $0 msaccess.mdb mysqldb mysqluser mysqlpass"
exit
fi

MDB_FILE=$1
MYSQL_DBNAME=$2
MYSQL_USER=$3
MYSQL_PASS=$4

MYSQL_IMPORT=/tmp/`basename $MDB_FILE .mdb`.sql

>$MYSQL_IMPORT

# create database
echo "DROP DATABASE IF EXISTS $MYSQL_DBNAME;" >> $MYSQL_IMPORT
echo "CREATE DATABASE $MYSQL_DBNAME; " >> $MYSQL_IMPORT
echo "USE $MYSQL_DBNAME; " >> $MYSQL_IMPORT

# import table structures with mysql data types
mdb-schema  $MDB_FILE mysql >> $MYSQL_IMPORT

perl -p -i -e 's/-----*/--/g' $MYSQL_IMPORT
perl -p -i -e 's/DROP TABLE (.*)/DROP TABLE IF EXISTS $1/gi' $MYSQL_IMPORT

# Fix the Variables
#perl -p -i -e 's/Text/VARCHAR/g' $MYSQL_IMPORT
#perl -p -i -e 's/Long Integer/INT\(11\)/g' $MYSQL_IMPORT

# import data
for TABLE in `mdb-tables $MDB_FILE`
do
echo " #### exporting table #### ${MDB_FILE} @@@@ ${TABLE} ..."
mdb-export -R ';' -I mysql $MDB_FILE  $TABLE >> $MYSQL_IMPORT

done
echo "######## done ...... Insert to MySql Server .... "
mysql -u$MYSQL_USER -p$MYSQL_PASS < $MYSQL_IMPORT

if [ $? -ne 0 ]; then
echo ""
echo "Fix the script at $MYSQL_IMPORT"
echo ""
echo "Run it using following command"
echo "mysql -u$MYSQL_USER -p$MYSQL_PASS < $MYSQL_IMPORT"
else
echo ""
echo "DONE. Script used is: $MYSQL_IMPORT"
echo ""
echo "Remove it if you no longer need it"
fi
