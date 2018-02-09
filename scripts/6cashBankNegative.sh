#! /bin/bash
mysql -u root -pConflux_159 --database=chaitanyax --host=chaitanya-cluster.cluster-ch6ojht2rfkb.ap-south-1.rds.amazonaws.com --port=7536  --batch -e "select gl.id,gl.name Account ,gl.gl_code GLCode,gl.classification_enum,
 case when gl.classification_enum in (1,5) then
 sum(case jd.type_enum when 2 then jd.amount else 0 end) -
 sum(case jd.type_enum when 1 then jd.amount else 0 end)  
 else sum(case jd.type_enum when 1 then jd.amount else 0 end) -
 sum(case jd.type_enum when 2 then jd.amount else 0 end) end  balance from 
f_journal_entry je
join f_journal_entry_detail jd on jd.journal_entry_id=je.id
join acc_gl_account gl on gl.id=jd.account_id
where (gl.name like '%BANK%' or gl.name like '%CASH%')
group by gl.id
having balance < 0" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > CashBank.csv


ttt=$(sed -n 2p CashBank.csv)
echo $ttt > CashBank.txt
yyy=$(cut -d '"' -f 2 CashBank.txt)

if [ $yyy -gt 0 ] 
then echo "Chaitanya Cash & Bank Accounts With Negative Balance" | mail -s "Cash & Bank Balance" -A CashBank.csv sughosh@confluxtechnologies.com -a "From: Conflux Technologies <support@confluxtechnologies.com>" -a "Cc:binny@confluxtechnologies.com,nayan@confluxtechnologies.com,ashok@confluxtechnologies.com,bharath.c@confluxtechnologies.com,venkat.ganesh@confluxtechnologies.com"
else echo "bye"
fi
