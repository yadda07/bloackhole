
CREATE OR REPLACE FUNCTION suppresions.delete_if_no_change()
RETURNS trigger
LANGUAGE 'plpgsql'
COST 100
VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
    target_table TEXT := TG_ARGV[0];  
    schema_name TEXT;
    table_name TEXT;
BEGIN
    schema_name := split_part(target_table, '.', 1);
    table_name := split_part(target_table, '.', 2);

    IF NEW.old_values = NEW.new_values THEN
        EXECUTE format(
            'DELETE FROM %I.%I WHERE audit_id = $1',
            schema_name, table_name
        ) USING NEW.audit_id;
        
        RETURN NULL;  
    END IF;
    RETURN NEW;
END;
$BODY$;

ALTER FUNCTION suppresions.delete_if_no_change()
    OWNER TO ownergrp_auvergne;

GRANT EXECUTE ON FUNCTION suppresions.delete_if_no_change() TO PUBLIC;

GRANT EXECUTE ON FUNCTION suppresions.delete_if_no_change() TO auvergne_rbal;

GRANT EXECUTE ON FUNCTION suppresions.delete_if_no_change() TO auvergne_sch_etudes;

GRANT EXECUTE ON FUNCTION suppresions.delete_if_no_change() TO cboulogne;

GRANT EXECUTE ON FUNCTION suppresions.delete_if_no_change() TO consult_auvergne;

GRANT EXECUTE ON FUNCTION suppresions.delete_if_no_change() TO ownergrp_auvergne;



CREATE OR REPLACE TRIGGER check_changement
    AFTER INSERT
    ON suppresions.aerien_json
    FOR EACH ROW
    EXECUTE FUNCTION suppresions.delete_if_no_change('suppresions.aerien_json');

CREATE OR REPLACE TRIGGER check_changement
    AFTER INSERT
    ON suppresions.aerien_json
    FOR EACH ROW
    EXECUTE FUNCTION suppresions.delete_if_no_change('suppresions.rip_avg_json');

