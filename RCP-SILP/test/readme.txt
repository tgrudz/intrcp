W katalogu s¹ przykladowe pliki testowe wejsciowe w formacie xml.

Program wymaga ustawienia zmiennych systemowych:
1) SILPDDIR
2) INTRCPDIR

Do wypisania zmiennych mo¿na uruchomiæ TestEnv.
U mnie wygl¹da to tak:

##############################################################################
Zmienna SILPDDIR --> c:/work
Zmienna INTRCPDIR --> RcpSilp
##############################################################################
Kalatog z plikami --> c:/work/RcpSilp
Plik logu --> c:/work/logs/RcpSilp.log
##############################################################################

Plik wejœciowy nale¿y przegraæ do c:/work/RcpSilp
Plik wyjœciowy pojawi siê w tym samym katalogu.

Kompilacja antem:
ant CreateJAR

Przyk³adowe uruchomienie programu:
rcpsilp-1.0.jar walerianzyndul

Da¿ bór !!