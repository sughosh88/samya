#! /bin/bash
mysql -u root -pConflux_159 --database=chaitanyax --host=chaitanya-cluster.cluster-ch6ojht2rfkb.ap-south-1.rds.amazonaws.com --port=7536  --batch -e "select t.loan_id 'Loan ID'
,t.office_id 'Office ID'
,(sum(case t.transaction_type_enum when 53 then t.interest_portion_derived else 0 end)-

  sum(case t.transaction_type_enum when 55 then t.interest_portion_derived else 0 end)) 'AccrualSuspence',

if(((select sum(ifnull(m.interest_charged_derived,0)) from m_loan m
where m.id = t.loan_id)-sum(case t.transaction_type_enum when 2 then t.interest_portion_derived else 0 end) )< 0,0,((select sum(ifnull(m.interest_charged_derived,0)) 
from m_loan m
where m.id = t.loan_id)-sum(case t.transaction_type_enum when 2 then t.interest_portion_derived else 0 end)))  'Outstanding'
 from  m_loan_transaction t
where t.transaction_type_enum in (53,55,10,2)
and t.is_reversed = 0
group by t.loan_id
having  AccrualSuspence > Outstanding
and AccrualSuspence <> 0" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > accrualSuspence.csv


ttt=$(sed -n 2p accrualSuspence.csv)
echo $ttt > accrualSuspence.txt
yyy=$(cut -d '"' -f 2 accrualSuspence.txt)

if [ $yyy -gt 0 ] 
then echo "Incorrect Suspence Accrual Transaction" | mail -s "Accrual Vs Journal Entry" -A accrualSuspence.csv sughosh@confluxtechnologies.com -a "From: Conflux Technologies <support@confluxtechnologies.com>" -a "Cc:binny@confluxtechnologies.com,nayan@confluxtechnologies.com,ashok@confluxtechnologies.com,bharath.c@confluxtechnologies.com,venkat.ganesh@confluxtechnologies.com"
else echo "bye"
fi
