#***************************************************
# Plik        : build.sh
#		Skrypt kompiluj±cy program 
# Wykorzystuje:
#		ant.
# Uwagi:
#		Potrzebuje JDK wersji co najmniej 1.5.0.1 
#		ant w wersji co najmniej 1.6.5.
	    
#***************************************************

#katalog z kompilatorem ant
#	ANT_HOME=/usr/local/ant
	
#katalog z kompilatorem java	
	export JAVA_HOME=/usr/java/jdk_silp
	
#sie¿ka do pliku ant
	#PATH=${PATH}:${ANT_HOME}/bin

#kompilacja klas i pakowanie w jar
ant

