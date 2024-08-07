-- RECOVER TABLE
CREATE TABLE suppresions.rip_avg_json (
    audit_id SERIAL PRIMARY KEY,
    table_name VARCHAR(255),
    operation_type VARCHAR(50),
    old_values JSONB,
    new_values JSONB,
    audit_timestamp TIMESTAMP DEFAULT NOW(),
    user_name VARCHAR(255)
);

-- DROIT
ALTER TABLE IF EXISTS suppresions.rip_avg_json OWNER to ownergrp_auvergne;
GRANT ALL ON TABLE suppresions.rip_avg_json TO engelvin_auvergne;
GRANT ALL ON TABLE suppresions.rip_avg_json TO ownergrp_auvergne;

--INDEX
CREATE INDEX ndx_rip_avg_json_table_name ON suppresions.rip_avg_json (table_name);
CREATE INDEX ndx_rip_avg_json_operation_type ON suppresions.rip_avg_json (operation_type);
CREATE INDEX ndx_rip_avg_json_audit_timestamp ON suppresions.rip_avg_json (audit_timestamp);
CREATE INDEX ndx_rip_avg_json_user_name ON suppresions.rip_avg_json (user_name);
CREATE INDEX ndx_rip_avg_json_table_op_time ON suppresions.rip_avg_json (table_name, operation_type, audit_timestamp);

    --FUN
    CREATE OR REPLACE FUNCTION suppresions.recover_json()
    RETURNS TRIGGER AS $$
    BEGIN
        IF TG_OP = 'DELETE' THEN
            INSERT INTO suppresions.rip_avg_json(table_name, operation_type, old_values, audit_timestamp, user_name)
            VALUES (TG_TABLE_NAME, 'DELETE', row_to_json(OLD), NOW(), current_user);
        ELSIF TG_OP = 'UPDATE' THEN
            INSERT INTO suppresions.rip_avg_json(table_name, operation_type, old_values, new_values, audit_timestamp, user_name)
            VALUES (TG_TABLE_NAME, 'UPDATE', row_to_json(OLD), row_to_json(NEW), NOW(), current_user);
        ELSIF TG_OP = 'INSERT' THEN
            INSERT INTO suppresions.rip_avg_json(table_name, operation_type, new_values, audit_timestamp, user_name)
            VALUES (TG_TABLE_NAME, 'INSERT', row_to_json(NEW), NOW(), current_user);
        END IF;
        RETURN NEW;
    END;
    $$ LANGUAGE plpgsql;


ALTER FUNCTION suppresions.recover_json()
    OWNER TO ownergrp_auvergne;
-- TRIGGERS
CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.attaches
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.bpe
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.cables
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.commentaire
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.communes_auvergne
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.etude_cap_ft
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.etude_comac
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.infra_pt_autres
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.infra_pt_chb
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.infra_pt_pot
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.t_cheminement
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.t_zpa
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.t_zpbo
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.za_nro
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();

CREATE TRIGGER recover_json
AFTER INSERT OR UPDATE OR DELETE ON rip_avg_nge.za_sro
FOR EACH ROW EXECUTE FUNCTION suppresions.recover_json();
