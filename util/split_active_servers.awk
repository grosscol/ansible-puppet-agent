# Awk script to split active-servers into heira data yaml files.
# awk -f split_active_servers.awk /path/to/active-servers
BEGIN{ servername="demo"}
{
  if(index($1,".") > 0 ){
    servername = $1;
  } 
  else {
    servername = $1".umdl.umich.edu"
  }

  filename = servername".yaml"

  print "---" > filename
  print "umich::purpose::tags:" >> filename
  for (i=2; i<=NF; i++){
    print "  - "$i >> filename
  }
}
END {}
