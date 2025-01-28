# Usamos la imagen oficial de PostgreSQL como base
FROM postgres:17.2-alpine

# Configuramos la zona horaria para el contenedor
ENV TZ=America/Asuncion

# Copiamos scripts de inicialización al directorio predeterminado de PostgreSQL
COPY initdb.d /docker-entrypoint-initdb.d/

# Exponemos el puerto predeterminado de PostgreSQL
EXPOSE 5432

# Configuramos un volumen para persistir los datos de la base de datos
VOLUME /var/lib/postgresql/data

# Healthcheck para verificar la disponibilidad de PostgreSQL
# Usamos variables de entorno para el usuario y la base de datos
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
  CMD pg_isready -U ${POSTGRES_USER} -d ${POSTGRES_DB} || exit 1

# Metadatos adicionales para el contenedor
LABEL maintainer="moisesvillalba@gmail.com" \
      version="1.0" \
      description="PostgreSQL 17.2 con configuración personalizada y scripts de inicialización"

# Establecemos PGDATA como variable de entorno (opcional)
# ENV PGDATA=/var/lib/postgresql/data/pgdata
