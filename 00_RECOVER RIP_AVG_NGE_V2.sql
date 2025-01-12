-- RECOVER TABLE
	CREATE TABLE suppresions.rbal_json (
    audit_id SERIAL PRIMARY KEY,
    table_name VARCHAR(255),
    operation_type VARCHAR(50),
    old_values JSONB,
    new_values JSONB,
    audit_timestamp TIMESTAMP DEFAULT NOW(),
    user_name VARCHAR(255)
);

-- DROIT
ALTER TABLE IF EXISTS suppresions.rbal_json OWNER to ownergrp_auvergne;
GRANT ALL ON TABLE suppresions.rbal_json TO engelvin_auvergne;
GRANT ALL ON TABLE suppresions.rbal_json TO ownergrp_auvergne;

--INDEX
CREATE INDEX ndx_rbal_json_table_name ON suppresions.rbal_json (table_name);
CREATE INDEX ndx_rbal_json_operation_type ON suppresions.rbal_json (operation_type);
CREATE INDEX ndx_rbal_json_audit_timestamp ON suppresions.rbal_json (audit_timestamp);
CREATE INDEX ndx_rbal_json_user_name ON suppresions.rbal_json (user_name);
CREATE INDEX ndx_rbal_json_table_op_time ON suppresions.rbal_json (table_name, operation_type, audit_timestamp);

 
CREATE OR REPLACE FUNCTION suppresions.recover_json()
RETURNS trigger
LANGUAGE plpgsql
AS $$
DECLARE
    target_table TEXT := TG_ARGV[0];  
    schema_name TEXT;
    table_name TEXT;
BEGIN
    schema_name := split_part(target_table, '.', 1);
    table_name := split_part(target_table, '.', 2);

    IF TG_OP = 'DELETE' THEN
        EXECUTE format(
            'INSERT INTO %I.%I (table_name, operation_type, old_values, audit_timestamp, user_name) VALUES ($1, $2, $3, $4, $5)',
            schema_name, table_name
        ) USING TG_TABLE_NAME, 'DELETE', row_to_json(OLD), NOW(), current_user;
    ELSIF TG_OP = 'UPDATE' THEN
        EXECUTE format(
            'INSERT INTO %I.%I (table_name, operation_type, old_values, new_values, audit_timestamp, user_name) VALUES ($1, $2, $3, $4, $5, $6)',
            schema_name, table_name
        ) USING TG_TABLE_NAME, 'UPDATE', row_to_json(OLD), row_to_json(NEW), NOW(), current_user;
    END IF;
    RETURN NEW;
END;
$$;



CREATE OR REPLACE TRIGGER recover_json
    AFTER  DELETE OR UPDATE 
    ON aerien.infra_pt_autres
    FOR EACH ROW
    EXECUTE FUNCTION suppresions.recover_json('suppresions.aerien_json');   

CREATE TRIGGER recover_json
AFTER  UPDATE OR DELETE ON rip_avg_nge.cables
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json('suppresions.rip_avg_json');

