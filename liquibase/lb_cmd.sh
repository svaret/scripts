USAGE="USAGE: lb_cmd.sh <liquibase command> [liquibase property file]"

java -jar $LIQUIBASE_JAR --version

if [ $# -eq 0 ]; then
  echo "ERROR: Missing liquibase command"
  echo $USAGE
  exit -1
fi

# liquibase-kommando
LIQUIBASE_CMD=$1

PROPERTY_FILE=$LIQUIBASE_DEV_HOME/liquibase.properties
if [ $# -eq 2 ]; then
  PROPERTY_FILE=$2
fi

if [ ! -f $PROPERTY_FILE ]; then
  echo "ERROR: Missing liquibase property file '$PROPERTY_FILE'"
  echo $USAGE
  exit -1
fi
echo "Using property file '$PROPERTY_FILE'."

# Prompt user to make sure he is in the right environment
cat 1>&2 $PROPERTY_FILE
read 1>&2 -p 'Continue [Y/N] ' continue
echo $continue
if [ $continue == 'N' -o $continue == 'n' ]; then
  echo
  echo "TERMINATING"
  exit
fi

# Sätt liquibase-konfiguration
LIQUIBASE_CONF=$LIQUIBASE_DEV_HOME/liquibase.conf
if [ ! -f $LIQUIBASE_CONF ]; then
  echo "ERROR: Missing liquibase config file '$LIQUIBASE_CONF'"
  echo $USAGE
  exit -1
fi
. $LIQUIBASE_CONF

# Information för att koppla upp sig mot den databas man vill arbeta mot.
LOCAL_MAVEN_REPO=C:/dev/maven/maven-repository
DATABASE_DRIVER_PATH=$LOCAL_MAVEN_REPO/mysql/mysql-connector-java/5.1.6/mysql-connector-java-5.1.6.jar
CLASSPATH="$DATABASE_DRIVER_PATH;$CLASSPATH"

# Exekverar liquibase-kommando
RUN_THIS="java -jar -Dfile.encoding=UTF-8 $LIQUIBASE_JAR --defaultsFile=$PROPERTY_FILE --classpath=$CLASSPATH --logLevel=finest $LIQUIBASE_CMD "
echo $RUN_THIS
banner $LIQUIBASE_CMD -w 1000
read -p 'Continue [Y/N] ' continue
if [ $continue == 'N' -o $continue == 'n' ]; then
  echo
  echo "TERMINATING"
  exit
fi

$RUN_THIS

