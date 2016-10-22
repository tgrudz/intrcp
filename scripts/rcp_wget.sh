haslo=$1
naz_plik_xml=$2
email=$3
date_from=$4
date_to=$5
wget --http-user=admin --http-passwd=$haslo -O $naz_plik_xml "http://10.0.184.100:8080/webrcp/services/xml/EwidCPPrac.do?ref=$email&ood=$date_from&odo=$date_to"
if [ $? = 0 ]; then
    exit 0
else
    exit 1
fi
