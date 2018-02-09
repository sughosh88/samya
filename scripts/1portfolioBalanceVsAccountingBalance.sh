#! /bin/bash
mysql -u root -pConflux_159 --database=chaitanyax --host=chaitanya.ch6ojht2rfkb.ap-south-1.rds.amazonaws.com --port=7536  --batch -e "select 
p.id ProductId,p.name Product,gl.id AccountId,gl.name Account,
sum(ml.principal_disbursed_derived-ifnull(b.bp,0)) PortfolioBalance,acc.bal AccountingBalance

from 
m_office mo
join m_office ounder on ounder.hierarchy like concat(mo.hierarchy, '%') 
and ounder.hierarchy like concat('.', '%') 
join m_client mg on mg.office_id = ounder.id
join m_loan ml on ml.client_id = mg.id
join m_product_loan p on p.id=ml.product_id
join acc_product_mapping ap on ap.product_id=p.id and ap.financial_account_type=2
join acc_gl_account gl on gl.id=ap.gl_account_id
left join
(select ifnull(t.loan_id,0) bl,sum(ifnull(t.principal_portion_derived,0)) bp
,ifnull(sum(t.interest_portion_derived),0) bi,
ifnull(sum(t.fee_charges_portion_derived),0)bf,
ifnull(sum(t.penalty_charges_portion_derived),0)bpe 
from m_loan_transaction  t
where  t.transaction_type_enum in  (2,6) 
and t.is_reversed = 0
and t.transaction_date <= curdate()
group by t.loan_id ) b on ml.id = b.bl

join (select gl.id,gl.name,
sum(case jd.type_enum when 2 then jd.amount else 0 end) - 
sum(case jd.type_enum when 1 then jd.amount else 0 end) bal
from f_journal_entry je
join f_journal_entry_detail jd on jd.journal_entry_id=je.id
#join acc_product_mapping ap on ap.gl_account_id=jd.account_id and ap.financial_account_type=2
join acc_gl_account gl on gl.id=jd.account_id
where gl.id in (select gl_account_id from acc_product_mapping where financial_account_type=2)
and gl.id <> 659
and je.entry_date <=curdate()
group by gl.id) acc on acc.id=gl.id


where  mo.id = 1
and ((ml.disbursedon_date <= curdate() and ml.loan_status_id=300)
or (ml.disbursedon_date <= curdate() and ifnull(ml.closedon_date,ml.writtenoffon_date) > curdate() and ml.loan_status_id in (600,601,700)))
and ap.gl_account_id <> 659
group by gl.id
having PortfolioBalance <> AccountingBalance" | sed 's/\t/","/g;s/^/"/;s/$/"/;s/\n//g' > portfolioBalanceVsAccountingBalance.csv


ttt=$(sed -n 2p portfolioBalanceVsAccountingBalance.csv)
echo $ttt > portfolioBalanceVsAccountingBalance.txt
yyy=$(cut -d '"' -f 2 portfolioBalanceVsAccountingBalance.txt)

if [ $yyy -gt 0 ] 
then echo "Chaitanya Portfolio Balance Mismatch Against Accounting Balance" | mail -s "Portfolio OS Vs Accounting OS" -A portfolioBalanceVsAccountingBalance.csv sughosh@confluxtechnologies.com -a "From: Conflux Technologies <support@confluxtechnologies.com>" -a "Cc:binny@confluxtechnologies.com,nayan@confluxtechnologies.com,ashok@confluxtechnologies.com,bharath.c@confluxtechnologies.com,venkat.ganesh@confluxtechnologies.com"
else echo "bye"
fi
