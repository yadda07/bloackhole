CREATE OR REPLACE FUNCTION metadata.insert_metadata_from_schema(p_schema_name TEXT)
RETURNS VOID AS $$
DECLARE
    rec RECORD;
    geom_rec RECORD;
    insert_query TEXT;
BEGIN
    FOR rec IN 
        SELECT 
            n.nspname AS schema_name,
            c.relname AS table_name,
            a.attname AS column_name,
            CASE
                WHEN t.typname = 'varchar' THEN
                    CASE
                        WHEN a.atttypmod > 4 THEN format('varchar(%s)', a.atttypmod - 4)
                        ELSE 'varchar'
                    END
                WHEN t.typname = 'bpchar' THEN
                    CASE
                        WHEN a.atttypmod > 4 THEN format('char(%s)', a.atttypmod - 4)
                        ELSE 'char'
                    END
                WHEN t.typname = 'numeric' THEN
                    CASE
                        WHEN a.atttypmod = -1 THEN 'numeric'
                        ELSE format('numeric(%s, %s)', ((a.atttypmod - 4) >> 16) & 65535, (a.atttypmod - 4) & 65535)
                    END
                WHEN t.typname = 'int4' THEN 'integer'
                WHEN t.typname = 'geometry' THEN 'geometry'  
            END AS type_column
        FROM 
            pg_attribute a
            JOIN pg_class c ON a.attrelid = c.oid
            JOIN pg_type t ON a.atttypid = t.oid
            JOIN pg_namespace n ON c.relnamespace = n.oid
        WHERE 
            a.attnum > 0 
            AND NOT a.attisdropped 
            AND n.nspname = p_schema_name
    LOOP
        IF rec.type_column = 'geometry' THEN
            FOR geom_rec IN
                SELECT f_geometry_column, type, srid
                FROM geometry_columns
                WHERE f_table_schema = rec.schema_name AND f_table_name = rec.table_name AND f_geometry_column = rec.column_name
            LOOP
                rec.type_column := format('geometry(%s, %s)', geom_rec.type, geom_rec.srid);
            END LOOP;
        END IF;

        insert_query := format(
            'INSERT INTO metadata.column_avg (schema_name, table_name, column_name, type_column) VALUES (%L, %L, %L, %L)',
            rec.schema_name, rec.table_name, rec.column_name, rec.type_column
        );
        EXECUTE insert_query;
    END LOOP;
END;
$$ LANGUAGE plpgsql;







SELECT metadata.insert_metadata_from_schema('rip_avg_engelvin');


SELECT * from metadata.column_avg 


DELETE FROM metadata.column_avg where schema_name = 'rip_avg_nge'


