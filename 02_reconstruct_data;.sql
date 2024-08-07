DROP FUNCTION IF EXISTS public.reconstruct_data;
CREATE OR REPLACE FUNCTION public.reconstruct_data(
    p_schema_name TEXT,
    p_table_name TEXT,
    p_operation VARCHAR(50),
    p_start_time TIMESTAMP,
    p_end_time TIMESTAMP
)
RETURNS TABLE(
    id INT, 
    operation_type VARCHAR(50), 
    operation_timestamp TIMESTAMP, 
    column_name TEXT, 
    column_value TEXT, 
    column_type TEXT
) AS $$
DECLARE
    record RECORD;
    query TEXT;
    col_type TEXT;
    col_name TEXT;
    col_value TEXT;
BEGIN
    query := format('SELECT audit_id, operation_type, audit_timestamp, old_values FROM %I.%I WHERE table_name = %L AND operation_type = %L AND audit_timestamp BETWEEN %L AND %L', 
                    p_schema_name, 'rip_avg_json', p_table_name, p_operation, p_start_time, p_end_time);

    RAISE NOTICE 'Requête %', query;

    FOR record IN EXECUTE query
    LOOP
        RAISE NOTICE 'Enregistrement: audit_id = %, operation_type = %, audit_timestamp = %, old_values = %', 
            record.audit_id, record.operation_type, record.audit_timestamp, record.old_values;
        
         FOR col_name, col_value IN
            SELECT key, value FROM jsonb_each_text(record.old_values)
        LOOP
            SELECT ca.type_column INTO col_type
            FROM metadata.column_avg ca
            WHERE ca.schema_name = p_schema_name
              AND ca.table_name = p_table_name
              AND ca.column_name = col_name;

            RAISE NOTICE 'Colonne: name = %, value = %, type = %', col_name, col_value, col_type;

            IF col_type IS NULL THEN
                RAISE NOTICE 'Type de colonne non trouvé pour %', col_name;
            END IF;

            RETURN QUERY
            SELECT record.audit_id, record.operation_type, record.audit_timestamp, col_name, col_value, col_type;
        END LOOP;
    END LOOP;
END;
$$ LANGUAGE plpgsql;




SELECT *  FROM public.reconstruct_data(
    'rip_avg_engelvin',
    'cables', 
    'UPDATE', 
    '2024-06-26 13:50:10', 
    '2024-06-26 13:53:50'
);
