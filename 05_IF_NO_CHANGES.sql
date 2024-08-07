
CREATE OR REPLACE FUNCTION suppresions.delete_if_no_change()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.old_values = NEW.new_values THEN
        DELETE FROM suppresions.rip_avg_json
        WHERE audit_id = NEW.audit_id;
        RETURN NULL;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER check_changement
AFTER INSERT ON suppresions.rip_avg_json
FOR EACH ROW
EXECUTE FUNCTION suppresions.delete_if_no_change();