test $SILPADIR || { echo "Nie ustawiona zmienna SILPADIR"; exit 1; }
test $SILPDDIR || { echo "Nie ustawiona zmienna SILPDDIR"; exit 1; }

test $DBSNAME || { echo "Nie ustawiona zmienna DBSNAME"; exit 1; }

if [ `uname` != Linux ]
then
   echo 'Aplikacja dzia³a tylko na serwerach z systemem operacyjnym LINUX'
   sleep 3
   exit 1
fi
if test -f $SILPADIR/${INTRCPDIR:-intrcp}/intrcp.env

then
   . $SILPADIR/${INTRCPDIR:-intrcp}/intrcp.env
else
   echo "Brak pliku intrcp.env"; exit 1
fi
test $INTRCPDIR || { echo "Nie ustawiona zmienna INTRCPDIR"; exit 1; }
test $INTRCPLOG || { echo "Nie ustawiona zmienna INTRCPLOG"; exit 1; }

cd $SILPADIR/$INTRCPDIR/bin
exec ./intrcp.4ge "$@"

