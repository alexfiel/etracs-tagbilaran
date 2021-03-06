[insertItems]
insert into draftremittanceitem ( 
	objid, remittanceid, controlid, 
	amount, totalnoncash, totalcash, 
	cancelled, voided 
)
select 
	c.objid, $P{remittanceid} as remittanceid, c.controlid, 
	c.amount, c.totalnoncash, (c.amount - c.totalnoncash) as totalcash, 
	(case when c.state = 'CANCELLED' then 1 else 0 end) as cancelled, 
	(
		select (case when count(*)>0 then 1 else 0 end) 
		from cashreceipt_void 
		where receiptid = c.objid 
	) as voided 
from cashreceipt c 
	inner join af_control afc on afc.objid = c.controlid 
	inner join af on (af.objid = afc.afid and af.formtype='serial') 
where c.collector_objid = $P{collectorid} 
	and c.remittanceid is null 
	and c.receiptdate < $P{txndate}  
	and c.state in ('POSTED','DELEGATED') 

[getAFSummary]
select 
	concat(rem.collector_objid, remi.remittanceid, c.controlid) as objid, 
	remi.remittanceid, rem.collector_objid, c.controlid, af.formtype, 
	afc.afid as formno, afc.stubno, afc.startseries, afc.endseries, 
	min(c.series) as fromseries, max(c.series) as toseries, count(*) as qty, 
	sum(remi.amount) as amount
from draftremittance rem 
	inner join draftremittanceitem remi on remi.remittanceid = rem.objid 
	inner join cashreceipt c on c.objid = remi.objid 
	inner join af_control afc on afc.objid = c.controlid 
	inner join af on af.objid = afc.afid 
where rem.objid = $P{remittanceid} 
group by concat(rem.collector_objid, remi.remittanceid, c.controlid), 
	remi.remittanceid, rem.collector_objid, c.controlid, af.formtype,
	afc.afid, afc.stubno, afc.startseries, afc.endseries 
order by afc.afid, afc.startseries 

[getVoidReceipts]
select 
	c.objid, c.receiptno, c.receiptdate, c.paidby, c.paidbyaddress, 
	c.amount, cv.txndate as void_txndate, cv.reason as void_reason 
from draftremittance rem 
	inner join draftremittanceitem remi on remi.remittanceid = rem.objid 
	inner join cashreceipt c on c.objid = remi.objid 
	inner join cashreceipt_void cv on cv.receiptid = c.objid 
	inner join af_control afc on afc.objid = c.controlid 
	inner join af on (af.objid = afc.afid and af.formtype = 'serial') 
where rem.objid = $P{remittanceid} 
order by c.receiptdate, c.receiptno  

[bindRemittance]
update cashreceipt c, draftremittanceitem remi set 
	c.remittanceid = remi.remittanceid 
where remi.remittanceid = $P{remittanceid} 
	and c.objid = remi.objid  
