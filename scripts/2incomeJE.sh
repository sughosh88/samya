#! /bin/bash
mysql -u root -pConflux_159 --database=chaitanyax --host=chaitanya-cluster.cluster-ch6ojht2rfkb.ap-south-1.rds.amazonaws.com --port=7536  --batch -e "select t.id,t.loan_id,ifnull(t.interest_portion_derived,0) portfolioInterest
,jd.amount IncomeReceivable,jd.type_enum,gl.name,p.name,jd.account_id
from m_loan_transaction t
join f_journal_entry je on je.entity_transaction_id=t.id and je.entity_type_enum=1
join f_journal_entry_detail jd on jd.journal_entry_id=je.id
join acc_gl_account gl on gl.id=jd.account_id
join m_loan l on l.id=t.loan_id
join m_product_loan p on p.id=l.product_id
where gl.id in (select ap.gl_account_id from acc_product_mapping ap where ap.financial_account_type=7 and ap.product_id=p.id)
and t.transaction_date > '2017-01-01'
and t.is_reversed=0
and t.transaction_type_enum=2
#and t.loan_id=467539
having portfolioInterest <> IncomeReceivable" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > incomeJE.csv


ttt=$(sed -n 2p incomeJE.csv)
echo $ttt > incomeJE.txt
yyy=$(cut -d '"' -f 2 incomeJE.txt)

if [ $yyy -gt 0 ] 
then echo "Chaitanya Interest Income Transaction Mismatch Against Journal Entry" | mail -s "Interest Income Vs Journal Entry" -A incomeJE.csv sughosh@confluxtechnologies.com -a "From: Conflux Technologies <support@confluxtechnologies.com>" -a "Cc:binny@confluxtechnologies.com,nayan@confluxtechnologies.com,ashok@confluxtechnologies.com,bharath.c@confluxtechnologies.com,venkat.ganesh@confluxtechnologies.com"
else echo "bye"
fi
