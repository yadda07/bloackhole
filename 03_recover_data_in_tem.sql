DROP FUNCTION IF EXISTS public.recover_data_in_temp;
CREATE OR REPLACE FUNCTION public.recover_data_in_temp(
    p_schema_name TEXT,
    p_table_name TEXT,
    p_operation VARCHAR(50),
    p_start_time TIMESTAMP,
    p_end_time TIMESTAMP
)
RETURNS VOID AS $$
DECLARE
    record RECORD;
    query TEXT;
    col_name TEXT;
    col_value TEXT;
    col_type TEXT;
    column_names TEXT;
    column_definitions TEXT;
    insert_cols TEXT;
    insert_vals TEXT;
BEGIN
    IF p_schema_name = 'suppresions' THEN
        SELECT string_agg(column_name, ', ') INTO column_names
        FROM metadata.column_avg
        WHERE schema_name = 'rip_avg_nge' AND table_name = p_table_name;
        
        SELECT string_agg(format('%I %s', column_name, type_column), ', ') INTO column_definitions
        FROM metadata.column_avg
        WHERE schema_name = 'rip_avg_nge' AND table_name = p_table_name;
    ELSE
        SELECT string_agg(column_name, ', ') INTO column_names
        FROM metadata.column_avg
        WHERE schema_name = 'rip_avg_engelvin' AND table_name = p_table_name;
        
        SELECT string_agg(format('%I %s', column_name, type_column), ', ') INTO column_definitions
        FROM metadata.column_avg
        WHERE schema_name = 'rip_avg_engelvin' AND table_name = p_table_name;
    END IF;
    EXECUTE format('DROP TABLE IF EXISTS temp_reconstruct_data ; CREATE TEMP TABLE temp_reconstruct_data (id INT, operation_type VARCHAR(50), operation_timestamp TIMESTAMP, %s)', column_definitions);
    query := format('SELECT audit_id, operation_type, audit_timestamp, old_values FROM %I.%I WHERE table_name = %L AND operation_type = %L AND audit_timestamp BETWEEN %L AND %L', 
                    p_schema_name, 'rip_avg_json', p_table_name, p_operation, p_start_time, p_end_time);

    RAISE NOTICE 'Query: %', query;
    FOR record IN EXECUTE query
    LOOP
        RAISE NOTICE 'Record: audit_id = %, operation_type = %, audit_timestamp = %, old_values = %', 
            record.audit_id, record.operation_type, record.audit_timestamp, record.old_values;
        insert_cols := 'id, operation_type, operation_timestamp';
        insert_vals := format('%L, %L, %L', record.audit_id, record.operation_type, record.audit_timestamp);
        FOR col_name, col_type IN
            SELECT column_name, type_column FROM metadata.column_avg
            WHERE ((schema_name = 'rip_avg_nge' AND p_schema_name = 'suppresions')
               OR (schema_name = 'rip_avg_engelvin' AND p_schema_name = 'suppresions_engelvin'))
              AND table_name = p_table_name
        LOOP
            col_value := record.old_values->>col_name;
            insert_cols := insert_cols || format(', %I', col_name);
            insert_vals := insert_vals || format(', %L::%s', col_value, col_type);
        END LOOP;
        EXECUTE format('INSERT INTO temp_reconstruct_data (%s) VALUES (%s)', insert_cols, insert_vals);
    END LOOP;
END;
$$ LANGUAGE plpgsql;





SELECT * FROM public.recover_data_in_temp(
    'suppresions',
    'bpe', 
    'DELETE', 
    '2024-03-01 13:50:10', 
    '2024-03-10 13:53:50'
);
 SELECT * from temp_reconstruct_data