USAGE="USAGE: lb_diff.sh <diff-mode> <base-db-props> <target-db-props>"
DIFF_MODE_HELP="(Where diff-mode is one of 'diff' or 'diffChangeLog'.)"

if [ $# -ne 3 ]; then
  echo "ERROR: Wrong number of arguments"
  echo $USAGE
  echo $DIFF_MODE_HELP
  exit -1
fi

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

# Sätt liquibase-konfiguration
LIQUIBASE_CONF=liquibase.conf
if [ ! -f $LIQUIBASE_CONF ]; then
  echo "ERROR: Missing liquibase config file '$LIQUIBASE_CONF'"
  echo $USAGE
  exit -1
fi
. $LIQUIBASE_CONF

# ******************
# Drivrutin databas
# ******************
LOCAL_MAVEN_REPO=C:/dev/maven/maven-repository
DRIVER_PATH=$LOCAL_MAVEN_REPO/mysql/mysql-connector-java/5.1.6/mysql-connector-java-5.1.6.jar

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
# java -jar $LIQUIBASE_JAR --classpath=$DRIVER_PATH --url=$URL \
#	--username=$USERNAME --password=$PASSWORD \
#	$DIFF_MODE \
#	--baseUrl=$BASE_URL --baseUsername=$BASE_USERNAME --basePassword=$BASE_PASSWORD

# 2.0 style
java -jar $LIQUIBASE_JAR --classpath=$DRIVER_PATH \
	--url=$OLD_DB_URL --username=$OLD_DB_USERNAME --password=$OLD_DB_PASSWORD \
	$DIFF_MODE \
	--referenceUrl=$NEW_DB_URL --referenceUsername=$NEW_DB_USERNAME --referencePassword=$NEW_DB_PASSWORD 
#	--defaultsFile=$LIQUIBASE_PROPERTIES

