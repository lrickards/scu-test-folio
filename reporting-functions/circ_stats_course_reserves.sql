--metadb:function circ_stats_course_reserves

DROP FUNCTION IF EXISTS circ_stats_course_reserves;
	
CREATE FUNCTION circ_stats_course_reserves(
	Circ_Stat_Course_Name text,
	start_date date DEFAULT '2000-01-01',
  	end_date date DEFAULT '2099-01-01'
)
returns table(
	item_barcode text,
	instance_title text,
	circ_count numeric
)
as $$
SELECT iext.barcode as item_barcode, inst.title as instance_title, count(lit.loan_id) as circ_count
from
	folio_courses.coursereserves_courses__t__ crct
	left join folio_courses.coursereserves_reserves__t__ crrt on crct.course_listing_id = crrt.course_listing_id
	left join folio_derived.item_ext iext on crrt.item_id = iext.item_id
	LEFT JOIN folio_derived.holdings_ext hrt on iext.holdings_record_id = hrt.holdings_id
	LEFT JOIN folio_derived.instance_ext inst on hrt.instance_id = inst.instance_id
	left join folio_derived.loans_items lit on crrt.item_id = lit.item_id 
WHERE
	crct.name ~ Circ_Stat_Course_Name 
	and start_date <= lit.loan_date and lit.loan_date <= end_date 
group by
	iext.barcode, inst.title, lit.loan_id
ORDER BY
	instance_title 
$$
language sql
STABLE 
PARALLEL SAFE; 
