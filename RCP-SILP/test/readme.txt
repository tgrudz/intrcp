W katalogu s� przykladowe pliki testowe wejsciowe w formacie xml.

Program wymaga ustawienia zmiennych systemowych:
1) SILPDDIR
2) INTRCPDIR

Do wypisania zmiennych mo�na uruchomi� TestEnv.
U mnie wygl�da to tak:

##############################################################################
Zmienna SILPDDIR --> c:/work
Zmienna INTRCPDIR --> RcpSilp
##############################################################################
Kalatog z plikami --> c:/work/RcpSilp
Plik logu --> c:/work/logs/RcpSilp.log
##############################################################################

Plik wej�ciowy nale�y przegra� do c:/work/RcpSilp
Plik wyj�ciowy pojawi si� w tym samym katalogu.

Kompilacja antem:
ant CreateJAR

Przyk�adowe uruchomienie programu:
rcpsilp-1.0.jar walerianzyndul

Da� b�r !!