--metadb:function circ_report

DROP FUNCTION IF EXISTS circ_report;
	
CREATE FUNCTION generate_circ_report(
	start_date date DEFAULT '2000-01-01',
  	end_date date DEFAULT '2099-01-01'
)
returns table(
  Item_UUID text,
  Item_Barcode text,
  Loan_Date date,
  Instance_String text,
  Location_String text,
  Call_Number text
)
as $$
  SELECT  
	ihi.item_id as "Item_UUID", 
	ihi.barcode as "Item_Barcode", 
	lt.loan_date as "Loan_Date",
	concat(ihi.title, ', ', ip.publisher, ', ', ip.date_of_publication) as "Instance_String",
	he.permanent_location_name as "Location_String",
	he.call_number as "Call_Number"
FROM 
	folio_derived.items_holdings_instances as ihi
	left join folio_derived.instance_contributors as ic on ihi.instance_id = ic.instance_id
	left join folio_derived.holdings_ext as he on ihi.holdings_id = he.holdings_id 
	left join folio_derived.instance_publication as ip on ihi.instance_id = ip.instance_id 
	left join folio_circulation.loan__t as lt on ihi.item_id = lt.item_id
where 
	lt.action = 'checkedout' AND 
  start_date <= lt.loan_date and lt.loan_date <= end_date
group by ihi.item_id, ihi.barcode, lt.loan_date, ihi.title, ip.publisher, ip.date_of_publication, he.permanent_location_name, he.call_number; 

$$
language sql
STABLE 
PARALLEL SAFE; 
