#! /bin/bash
mysql -u root -pConflux_159 --database=chaitanyax --host=chaitanya-cluster.cluster-ch6ojht2rfkb.ap-south-1.rds.amazonaws.com --port=7536  --batch -e "select sum(case fd.type_enum when 1 then fd.amount else 0 end) credit
 ,sum(case fd.type_enum when 2 then fd.amount else 0 end) debit
 from f_journal_entry_detail fd
 join f_journal_entry je on je.id=fd.journal_entry_id
 where je.entry_date between adddate(curdate(),-365) and curdate()
 having credit <> debit" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > creditVsDebit.csv


ttt=$(sed -n 2p creditVsDebit.csv)
echo $ttt > creditVsDebit.txt
yyy=$(cut -d '"' -f 2 creditVsDebit.txt)

if [ $yyy -gt 0 ] 
then echo "Chaitanya Total Credits Vs Total Debits Between Past 12 Months" | mail -s "Total Credits Vs Debits" -A creditVsDebit.csv sughosh@confluxtechnologies.com -a "From: Conflux Technologies <support@confluxtechnologies.com>" -a "Cc:binny@confluxtechnologies.com,nayan@confluxtechnologies.com,ashok@confluxtechnologies.com,bharath.c@confluxtechnologies.com,venkat.ganesh@confluxtechnologies.com"
else echo "bye"
fi
