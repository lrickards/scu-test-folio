--metadb:function pop_usage; not currently in a usable state

DROP FUNCTION IF EXISTS pop_usage;
	
CREATE FUNCTION zero_use_items(
	start_date date DEFAULT '2000-01-01',
	end_date date DEFAULT '2099-01-01'
)
returns table(
	Item_ID text,
	Title text
)
as $$
select iit.id AS Item_ID, instancet.title as Title
	from folio_inventory.item__t__ as iit 
		JOIN folio_inventory.holdings_record__t__ as hrt on iit.holdings_record_id = hrt.id
		JOIN folio_inventory.instance__t__ as instancet ON instancet.id = hrt.instance_id
	WHERE
	NOT EXISTS (
		SELECT  -- SELECT list mostly irrelevant; can just be empty in Postgres
		FROM   folio_circulation.check_in__t__ as cit
		WHERE  cit.item_id = it.id
    ) and
    itt.__current = true and
    hrt.permanent_location_id = '59788294-9e3c-5b48-97d7-280067071b70' and
    start_date <= cit.occurred_date_time and cit.occurred_date_time <= end_date
$$
language sql
STABLE 
PARALLEL SAFE; 
