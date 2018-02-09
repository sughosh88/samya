#! /bin/bash
mysql -u root -pConflux_159 --database=chaitanyax --host=chaitanya-cluster.cluster-ch6ojht2rfkb.ap-south-1.rds.amazonaws.com --port=7536  --batch -e "select t.id TransactionID 
,t.amount TransactionAmount
,t.loan_id LoanID
,t.transaction_date TransactionDate
,sum(jd.amount) JournalEntryAmount
from m_loan_transaction t
join f_journal_entry je on je.entity_transaction_id=t.id and je.entity_type_enum=1
join f_journal_entry_detail jd on jd.journal_entry_id=je.id and jd.type_enum=1
where t.transaction_type_enum=10
and t.is_reversed=0
and t.transaction_date between adddate(curdate(),-30) and curdate()
#and t.id not in (913096,916404)
group by 1
having t.amount <> sum(jd.amount)" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > accrualJE.csv


ttt=$(sed -n 2p accrualJE.csv)
echo $ttt > accrualJE.txt
yyy=$(cut -d '"' -f 2 accrualJE.txt)

if [ $yyy -gt 0 ] 
then echo "Chaitanya Accrual Transaction Mismatch Against Journal Entry" | mail -s "Accrual Vs Journal Entry" -A accrualJE.csv sughosh@confluxtechnologies.com -a "From: Conflux Technologies <support@confluxtechnologies.com>" -a "Cc:binny@confluxtechnologies.com,nayan@confluxtechnologies.com,ashok@confluxtechnologies.com,bharath.c@confluxtechnologies.com,venkat.ganesh@confluxtechnologies.com"
else echo "bye"
fi
