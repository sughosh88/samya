#! /bin/bash
mysql -u root -pConflux_159 --database=chaitanyax --host=chaitanya-cluster.cluster-ch6ojht2rfkb.ap-south-1.rds.amazonaws.com --port=7536  --batch -e "select t.id TransactionId
,t.loan_id LoanId
,t2.id DuplicateTransactionId
,t.transaction_date TransactionDate
,t.amount Amount
from m_loan_transaction t
join m_loan_transaction t2 on t2.loan_id=t.loan_id and t2.transaction_date=t.transaction_date and t2.amount=t.amount and t2.id > t.id and t2.is_reversed=0 and t2.transaction_type_enum=2
where t.is_reversed=0
and t.transaction_type_enum =2" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > duplicateTrxn.csv


ttt=$(sed -n 2p duplicateTrxn.csv)
echo $ttt > duplicateTrxn.txt
yyy=$(cut -d '"' -f 2 duplicateTrxn.txt)

if [ $yyy -gt 0 ] 
then echo "Chaitanya Duplicate Transactions" | mail -s "Possible Duplicate Transaction" -A duplicateTrxn.csv sughosh@confluxtechnologies.com -a "From: Conflux Technologies <support@confluxtechnologies.com>" -a "Cc:binny@confluxtechnologies.com,nayan@confluxtechnologies.com,ashok@confluxtechnologies.com,bharath.c@confluxtechnologies.com,venkat.ganesh@confluxtechnologies.com"
else echo "bye"
fi
