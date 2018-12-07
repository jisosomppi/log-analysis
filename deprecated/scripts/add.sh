# https://stackoverflow.com/questions/1435000/

for certDB in $(find  ~/.mozilla* -name "cert8.db")
do
  certDir=$(dirname ${certDB});
  #log "mozilla certificate" "install '000logserver.local' in ${certDir}"
 certutil -A -n "000logserver.local" -t "TCu,Cuw,Tuw" -i localCA.pfx -d ${certDir}
done
