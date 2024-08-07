DROP FUNCTION IF EXISTS public.dynamic_reconstruct_data;

CREATE OR REPLACE FUNCTION public.dynamic_reconstruct_data(
    p_schema_name TEXT,
    p_table_name TEXT,
    p_operation VARCHAR(8),
    p_start_time TIMESTAMP,
    p_end_time TIMESTAMP
)
RETURNS VOID AS $$
DECLARE
    record RECORD;
    query TEXT;
    col_type TEXT;
    col_name TEXT;
    col_value TEXT;
    insert_query TEXT;
    column_list TEXT;
    value_list TEXT;
BEGIN
    query := format('SELECT audit_id, operation_type, audit_timestamp, old_values FROM suppresions_engelvin.rip_avg_json WHERE table_name = %L AND operation_type = %L AND audit_timestamp BETWEEN %L AND %L', 
                    p_table_name, p_operation, p_start_time, p_end_time);

    FOR record IN EXECUTE query
    LOOP
        column_list := '';
        value_list := '';

        FOR col_name, col_value IN
            SELECT key, value FROM jsonb_each_text(record.old_values)
        LOOP
            IF col_name = 'gid' THEN
                CONTINUE;
            END IF;

            SELECT ca.type_column INTO col_type
            FROM metadata.column_avg ca
            WHERE ca.schema_name = p_schema_name
              AND ca.table_name = p_table_name
              AND ca.column_name = col_name;

            IF col_type IS NULL THEN
                RAISE NOTICE 'Column type not found for %', col_name;
                col_type := 'TEXT';
            END IF;

            column_list := column_list || col_name || ', ';
            value_list := value_list || format('cast(%L as %s)', col_value, col_type) || ', ';
        END LOOP;

        column_list := rtrim(column_list, ', ');
        value_list := rtrim(value_list, ', ');

        insert_query := format('INSERT INTO %I.%I (%s) VALUES (%s)', p_schema_name, p_table_name, column_list, value_list);

        EXECUTE insert_query;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

--SELECT * from rip_avg_engelvin.cables

SELECT * 
FROM public.dynamic_reconstruct_data(
    'rip_avg_engelvin',
    'cables', 
    'UPDATE', 
    '2024-06-26 13:50:10', 
    '2024-06-26 13:53:50'
);