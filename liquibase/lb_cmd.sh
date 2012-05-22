USAGE="USAGE: lb_cmd.sh <liquibase command> [liquibase property file]"

if [ -z $LIQUIBASE_DEV_HOME ]; then
	echo "LIQUIBASE_DEV_HOME not set. Using current directory."
	LIQUIBASE_DEV_HOME=.
fi

# read liquibase configuration
LIQUIBASE_CONF=$LIQUIBASE_DEV_HOME/liquibase.conf
if [ ! -f $LIQUIBASE_CONF ]; then
  echo "ERROR: Missing liquibase config file '$LIQUIBASE_CONF'"
  echo $USAGE
  exit -1
fi
. $LIQUIBASE_CONF

java -jar $LIQUIBASE_JAR --version

#while getopts c: option
#do
#	case $option in
#	c) CONTEXT="--contexts=""$OPTARG";;
#	esac
#done
#shift $(($OPTIND -1))

#if [ $# -eq 0 ]; then
#  echo "ERROR: Missing liquibase command"
#  echo $USAGE
#  exit -1
#fi

# liquibase command
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

CLASSPATH="$DB_DRIVER"

# Execute liquibase command
RUN_THIS="java -jar -Dfile.encoding=UTF-8 $LIQUIBASE_JAR --defaultsFile=$PROPERTY_FILE \
--classpath=$CLASSPATH --logLevel=debug $CONTEXT $LIQUIBASE_CMD"
if [ ! -z $LIQUIBASE_CMD ]; then
	echo $RUN_THIS
	echo $LIQUIBASE_CMD
	read -p 'Continue [Y/N] ' continue
	if [ $continue == 'N' -o $continue == 'n' ]; then
	  echo
	  echo "TERMINATING"
	  exit
	fi
fi
	
$RUN_THIS

