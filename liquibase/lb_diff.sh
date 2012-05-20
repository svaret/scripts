USAGE="USAGE: lb_diff.sh <diff-mode> <base-db-props> <target-db-props>"
DIFF_MODE_HELP="(Where diff-mode is one of 'diff' or 'diffChangeLog'.)"

# liquibase configuration
LIQUIBASE_CONF=liquibase.conf
if [ ! -f $LIQUIBASE_CONF ]; then
  echo "ERROR: Missing liquibase config file '$LIQUIBASE_CONF'"
  echo $USAGE
  exit -1
fi
. $LIQUIBASE_CONF

liquibaseVersion=`java -jar $LIQUIBASE_JAR --version`
echo "$liquibaseVersion"

if [ $# -ne 3 ]; then
  echo "ERROR: Wrong number of arguments"
  echo $USAGE
  echo $DIFF_MODE_HELP
  exit -1
fi

# Set version specific stuff
versionStr=`echo "$liquibaseVersion" | sed "s/Liqui[Bb]ase Version: //"` 
case $versionStr in
  1.9.3)
    logLevel=finest;
    ;;
  1.9.5)
    logLevel=finest;
    ;;
  2.0.3)
    logLevel=debug;
    ;;
esac

DIFF_MODE=$1
if [ $DIFF_MODE != 'diff' -a $DIFF_MODE != 'diffChangeLog' ]; then
  echo "ERROR: diff-mode must be diff or diffChangeLog"
  echo $USAGE
  exit -1
fi

# setting properties for old and new database
OLD_DB_PROPS=$2
NEW_DB_PROPS=$3

if [ ! -f $OLD_DB_PROPS ]; then
  echo "ERROR: Missing property file '$OLD_DB_PROPS'"
  echo $USAGE
  exit -1
fi
if [ ! -f $NEW_DB_PROPS ]; then
  echo "ERROR: Missing property file '$NEW_DB_PROPS'"
  echo $USAGE
  exit -1
fi

# ***********************************************************************
# Information för att koppla upp sig mot de databaser man vill jämföra
# ***********************************************************************
. $NEW_DB_PROPS
NEW_DB_URL=$DB_URL
NEW_DB_USERNAME=$DB_USER
NEW_DB_PASSWORD=$DB_PWD

. $OLD_DB_PROPS
OLD_DB_URL=$DB_URL
OLD_DB_USERNAME=$DB_USER
OLD_DB_PASSWORD=$DB_PWD

# Exekverar liquibase-kommando
# 1.x style
case $versionStr in
  1.9.3)
java -jar $LIQUIBASE_JAR --classpath=$DB_DRIVER --logLevel=$logLevel --url=$OLD_DB_URL \
	--username=$OLD_DB_USERNAME --password=$OLD_DB_PASSWORD \
	$DIFF_MODE \
	--baseUrl=$NEW_DB_URL --baseUsername=$NEW_DB_USERNAME --basePassword=$NEW_DB_PASSWORD
    ;;
  1.9.5)
java -jar $LIQUIBASE_JAR --classpath=$DB_DRIVER --logLevel=$logLevel --url=$OLD_DB_URL \
	--username=$OLD_DB_USERNAME --password=$OLD_DB_PASSWORD \
	$DIFF_MODE \
	--baseUrl=$NEW_DB_URL --baseUsername=$NEW_DB_USERNAME --basePassword=$NEW_DB_PASSWORD
    ;;
  2.0.3)
java -jar $LIQUIBASE_JAR --classpath=$DB_DRIVER --logLevel=$logLevel \
	--url=$OLD_DB_URL --username=$OLD_DB_USERNAME --password=$OLD_DB_PASSWORD \
	$DIFF_MODE \
	--referenceUrl=$NEW_DB_URL --referenceUsername=$NEW_DB_USERNAME --referencePassword=$NEW_DB_PASSWORD 
#	--defaultsFile=$LIQUIBASE_PROPERTIES
    ;;
esac
