-- Configurar las variables desde parámetros de entorno
DO $$ 
BEGIN
    -- Variables dinámicas
    PERFORM set_config('custom.database_name', current_setting('custom.database_name', true), true);
    PERFORM set_config('custom.user_name', current_setting('custom.user_name', true), true);
    PERFORM set_config('custom.user_password', current_setting('custom.user_password', true), true);

    -- Verifica si las variables están definidas
    IF current_setting('custom.database_name', true) IS NULL THEN
        RAISE EXCEPTION 'Falta el parámetro "custom.database_name".';
    END IF;
    IF current_setting('custom.user_name', true) IS NULL THEN
        RAISE EXCEPTION 'Falta el parámetro "custom.user_name".';
    END IF;
    IF current_setting('custom.user_password', true) IS NULL THEN
        RAISE EXCEPTION 'Falta el parámetro "custom.user_password".';
    END IF;
END $$;

-- Crear la base de datos si no existe
DO $$ 
DECLARE
    db_name TEXT := current_setting('custom.database_name');
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_database WHERE datname = db_name) THEN
        EXECUTE format('CREATE DATABASE %I;', db_name);
        RAISE NOTICE 'Base de datos "%" creada exitosamente.', db_name;
    ELSE
        RAISE NOTICE 'Base de datos "%" ya existe.', db_name;
    END IF;
END $$;

-- Crear el usuario si no existe
DO $$ 
DECLARE
    user_name TEXT := current_setting('custom.user_name');
    user_password TEXT := current_setting('custom.user_password');
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = user_name) THEN
        EXECUTE format('CREATE USER %I WITH PASSWORD %L;', user_name, user_password);
        RAISE NOTICE 'Usuario "%" creado exitosamente.', user_name;
    ELSE
        RAISE NOTICE 'Usuario "%" ya existe.', user_name;
    END IF;
END $$;

-- Conceder privilegios al usuario en la base de datos
DO $$ 
DECLARE
    db_name TEXT := current_setting('custom.database_name');
    user_name TEXT := current_setting('custom.user_name');
BEGIN
    IF EXISTS (SELECT 1 FROM pg_roles WHERE rolname = user_name) THEN
        EXECUTE format('GRANT ALL PRIVILEGES ON DATABASE %I TO %I;', db_name, user_name);
        RAISE NOTICE 'Privilegios concedidos al usuario "%" en la base de datos "%".', user_name, db_name;
    ELSE
        RAISE WARNING 'Usuario "%" no existe. No se pueden conceder privilegios.', user_name;
    END IF;
END $$;

-- Crear el esquema si no existe
DO $$ 
DECLARE
    schema_name TEXT := 'biblio';  -- Puedes parametrizar este valor también si lo necesitas
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_namespace WHERE nspname = schema_name) THEN
        EXECUTE format('CREATE SCHEMA %I;', schema_name);
        RAISE NOTICE 'Esquema "%" creado exitosamente.', schema_name;
    ELSE
        RAISE NOTICE 'Esquema "%" ya existe.', schema_name;
    END IF;
END $$;
