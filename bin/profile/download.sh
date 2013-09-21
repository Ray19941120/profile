#!/bin/sh
URL="${1:?Please specify the URL to download}"
PROTO="${URL%://*}"
PATH="${URL##*//}"
SERVER="${PATH%%/*}"
SUBPATH="${PATH#*/}"

# Find the file transfer tool
if [ "$PROTO" == "ftp" ]; then
	TOOLS="curl ftp"
else
	TOOLS="curl wget"
fi
for TOOL in $TOOLS; do
	if command -v $TOOL 2>&1 >/dev/null; then
		break;
	fi
	TOOL=""
done
if [ -z "$TOOL" ]; then
	echo "No tool available in [ $TOOLS ], cannot go on..."
	exit 1
fi

# Get Usename & password
echo "Protocol: $PROTO"
read -p "User: " ACCOUNT
trap "stty echo; trap '' SIGINT" SIGINT; stty -echo
read -p "Password: " PASSWD
stty echo; trap "" SIGINT

# Proceed with file transfer
case $TOOL in
	curl)
		curl -u $ACCOUNT:$PASSWD -O "$URL" ;;
	wget)
		wget --user="$ACCOUNT" --password="$PASSWD" "$URL" ;;
	ftp)
		ftp -n -i -d <<END_SCRIPT
			open ${SERVER}
			user ${ACCOUNT}
			bin
			get ${SUBPATH}
			quit
END_SCRIPT
		;;
esac
exit 0
