current_date=`date +%Y-%m-%d:%H:%M:%S`
mysqldump -h localhost -uroot -p13JaPWh21x0q97JrHIMy mdk_production >/root/db_bak/apollo_"$current_date".sql
