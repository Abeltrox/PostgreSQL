-- =====================================================
-- TALLER: Consultas de fechas, DateTime e Intervalos
-- Tabla base: reservas
-- =====================================================


-- =====================================================
-- Caso de uso 1
-- Reservas posteriores al 16 de septiembre de 2026
-- =====================================================
-- Lógica: se compara la columna DATE fecha_reserva contra una fecha
-- literal usando el operador ">" (estrictamente posterior).
SELECT id, cliente, sala, fecha_reserva
FROM reservas
WHERE fecha_reserva > '2026-09-16';


-- =====================================================
-- Caso de uso 2
-- Reservas entre el 15 y el 25 de septiembre de 2026 (ambas incluidas)
-- =====================================================
-- Lógica: BETWEEN incluye los dos extremos del rango, por lo que es
-- el operador adecuado para "entre X y Y incluyendo ambas fechas".
SELECT id, cliente, sala, fecha_reserva
FROM reservas
WHERE fecha_reserva BETWEEN '2026-09-15' AND '2026-09-25';


-- =====================================================
-- Caso de uso 3
-- Reservas del día actual
-- =====================================================
-- Lógica: CURRENT_DATE devuelve la fecha del servidor en el momento
-- de ejecución, evitando escribir la fecha manualmente.
SELECT id, cliente, sala, fecha_reserva
FROM reservas
WHERE fecha_reserva = CURRENT_DATE;


-- =====================================================
-- Caso de uso 4
-- Reservas que todavía no han iniciado
-- =====================================================
-- Lógica: se compara el TIMESTAMPTZ de inicio contra el instante
-- actual (CURRENT_TIMESTAMP). Si el inicio es posterior, aún no comienza.
SELECT id, cliente, sala, fecha_hora_inicio
FROM reservas
WHERE fecha_hora_inicio > CURRENT_TIMESTAMP;


-- =====================================================
-- Caso de uso 5
-- Reservas que ya finalizaron
-- =====================================================
-- Lógica: si la hora de fin ya pasó respecto al instante actual,
-- la reserva se considera finalizada.
SELECT cliente, sala, fecha_hora_inicio, fecha_hora_fin
FROM reservas
WHERE fecha_hora_fin < CURRENT_TIMESTAMP;


-- =====================================================
-- Caso de uso 6
-- Reservas activas en este momento
-- =====================================================
-- Lógica: una reserva está activa si el instante actual cae dentro
-- del intervalo [fecha_hora_inicio, fecha_hora_fin].
SELECT id, cliente, sala, fecha_hora_inicio, fecha_hora_fin
FROM reservas
WHERE fecha_hora_inicio <= CURRENT_TIMESTAMP
  AND fecha_hora_fin   >= CURRENT_TIMESTAMP;


-- =====================================================
-- Caso de uso 7
-- Duración de cada reserva
-- =====================================================
-- Lógica: restar dos TIMESTAMPTZ en PostgreSQL produce un INTERVAL,
-- que representa la duración de la reserva.
SELECT cliente, sala, (fecha_hora_fin - fecha_hora_inicio) AS duracion
FROM reservas;


-- =====================================================
-- Caso de uso 8
-- Reservas largas (duración mayor a 2 horas)
-- =====================================================
-- Lógica: se calcula el INTERVAL de duración y se compara contra
-- un INTERVAL literal de 2 horas.
SELECT cliente, sala, (fecha_hora_fin - fecha_hora_inicio) AS duracion
FROM reservas
WHERE (fecha_hora_fin - fecha_hora_inicio) > INTERVAL '2 hours';


-- =====================================================
-- Caso de uso 9
-- Nueva hora de fin para reservas confirmadas (+30 minutos)
-- =====================================================
-- Lógica: sumar un INTERVAL a un TIMESTAMPTZ desplaza la fecha/hora
-- sin alterar los datos originales de la tabla (solo se muestra).
SELECT cliente,
       fecha_hora_fin,
       (fecha_hora_fin + INTERVAL '30 minutes') AS nueva_fecha_hora_fin
FROM reservas
WHERE estado = 'CONFIRMADA';


-- =====================================================
-- Caso de uso 10
-- Fecha límite de cancelación gratuita (24 horas antes del inicio)
-- =====================================================
-- Lógica: restar un INTERVAL de 24 horas al inicio da el límite
-- máximo para cancelar sin costo.
SELECT cliente,
       fecha_hora_inicio,
       (fecha_hora_inicio - INTERVAL '24 hours') AS fecha_limite_cancelacion
FROM reservas;


-- =====================================================
-- Caso de uso 11
-- Hora del día en que comienza cada reserva
-- =====================================================
-- Lógica: EXTRACT(HOUR FROM ...) obtiene únicamente el componente
-- de hora de un TIMESTAMPTZ.
SELECT cliente, EXTRACT(HOUR FROM fecha_hora_inicio) AS hora_inicio
FROM reservas;


-- =====================================================
-- Caso de uso 12
-- Año, mes, día y hora de inicio de cada reserva
-- =====================================================
-- Lógica: EXTRACT permite obtener cada componente individual de una
-- fecha/hora (YEAR, MONTH, DAY, HOUR).
SELECT cliente,
       EXTRACT(YEAR  FROM fecha_hora_inicio) AS anio,
       EXTRACT(MONTH FROM fecha_hora_inicio) AS mes,
       EXTRACT(DAY   FROM fecha_hora_inicio) AS dia,
       EXTRACT(HOUR  FROM fecha_hora_inicio) AS hora
FROM reservas;


-- =====================================================
-- Caso de uso 13
-- Cantidad de reservas por mes
-- =====================================================
-- Lógica: se extraen año y mes de fecha_hora_inicio y se agrupan
-- ambos valores para contar cuántas reservas caen en cada combinación.
SELECT EXTRACT(YEAR  FROM fecha_hora_inicio) AS anio,
       EXTRACT(MONTH FROM fecha_hora_inicio) AS mes,
       COUNT(*) AS cantidad_reservas
FROM reservas
GROUP BY anio, mes
ORDER BY anio, mes;


-- =====================================================
-- Caso de uso 14
-- Reservas del mes actual
-- =====================================================
-- Lógica: DATE_TRUNC('month', ...) reduce una fecha al primer día de
-- su mes; comparando el truncado de fecha_reserva contra el truncado
-- de CURRENT_DATE se obtiene el mes en curso sin importar cuál sea.
SELECT id, cliente, sala, fecha_reserva
FROM reservas
WHERE DATE_TRUNC('month', fecha_reserva) = DATE_TRUNC('month', CURRENT_DATE);


-- =====================================================
-- Caso de uso 15
-- Reservas creadas durante el año actual
-- =====================================================
-- Lógica: se trunca fecha_creacion y CURRENT_DATE al nivel de año
-- para comparar sin escribir el año manualmente.
SELECT id, cliente, sala, fecha_creacion
FROM reservas
WHERE DATE_TRUNC('year', fecha_creacion) = DATE_TRUNC('year', CURRENT_DATE);


-- =====================================================
-- Caso de uso 16
-- Reservas de la semana actual
-- =====================================================
-- Lógica: DATE_TRUNC('week', ...) lleva cualquier fecha al lunes de
-- su semana; al igualar el truncado de fecha_reserva con el de
-- CURRENT_DATE se filtra la semana en curso.
SELECT id, cliente, sala, fecha_reserva
FROM reservas
WHERE DATE_TRUNC('week', fecha_reserva) = DATE_TRUNC('week', CURRENT_DATE);


-- =====================================================
-- Caso de uso 17
-- Formato de fecha y hora: DD/MM/YYYY HH24:MI
-- =====================================================
-- Lógica: TO_CHAR aplica una máscara de formato a un TIMESTAMPTZ y
-- devuelve el resultado como texto.
SELECT cliente,
       TO_CHAR(fecha_hora_inicio, 'DD/MM/YYYY HH24:MI') AS fecha_hora_formateada
FROM reservas;


-- =====================================================
-- Caso de uso 18
-- Reporte combinado: Cliente | Sala | Fecha
-- =====================================================
-- Lógica: se concatenan columnas de texto con el operador || y se
-- aplica TO_CHAR al campo de fecha dentro de la misma expresión.
SELECT cliente || ' | ' || sala || ' | ' ||
       TO_CHAR(fecha_hora_inicio, 'DD/MM/YYYY HH24:MI') AS reporte
FROM reservas;


-- =====================================================
-- Caso de uso 19
-- Hora en Colombia y en Madrid para cada reserva
-- =====================================================
-- Lógica: AT TIME ZONE convierte un TIMESTAMPTZ a la hora local de
-- la zona horaria indicada.
SELECT cliente,
       fecha_hora_inicio AT TIME ZONE 'America/Bogota' AS hora_colombia,
       fecha_hora_inicio AT TIME ZONE 'Europe/Madrid'  AS hora_madrid
FROM reservas;


-- =====================================================
-- Caso de uso 20
-- Fechas de inicio expresadas en UTC
-- =====================================================
-- Lógica: AT TIME ZONE 'UTC' transforma el instante almacenado a la
-- hora universal coordinada.
SELECT cliente,
       fecha_hora_inicio AT TIME ZONE 'UTC' AS fecha_hora_inicio_utc
FROM reservas;


-- =====================================================
-- Caso de uso 21
-- Días faltantes para cada reserva
-- =====================================================
-- Lógica: restar dos valores DATE (fecha_reserva - CURRENT_DATE)
-- produce un entero con la cantidad de días de diferencia; puede ser
-- negativo si la reserva ya pasó.
SELECT cliente,
       fecha_reserva,
       (fecha_reserva - CURRENT_DATE) AS dias_faltantes
FROM reservas;


-- =====================================================
-- Caso de uso 22
-- Reservas creadas con al menos 5 días de anticipación
-- =====================================================
-- Lógica: fecha_creacion es TIMESTAMPTZ y fecha_reserva es DATE, por
-- lo que se convierte fecha_creacion a DATE (::date) antes de restar,
-- comparando el resultado entero contra 5.
SELECT id, cliente, fecha_reserva, fecha_creacion
FROM reservas
WHERE (fecha_reserva - fecha_creacion::date) >= 5;


-- =====================================================
-- Caso de uso 23
-- Reservas de último minuto (menos de 24 horas de anticipación)
-- =====================================================
-- Lógica: se calcula el INTERVAL entre la creación y el inicio real
-- (ambos TIMESTAMPTZ) y se compara contra 24 horas.
SELECT id, cliente, fecha_creacion, fecha_hora_inicio
FROM reservas
WHERE (fecha_hora_inicio - fecha_creacion) < INTERVAL '24 hours';


-- =====================================================
-- Caso de uso 24
-- Tiempo transcurrido entre creación e inicio (AGE)
-- =====================================================
-- Lógica: AGE(fin, inicio) devuelve un INTERVAL "legible" (años,
-- meses, días, horas) con la diferencia entre dos marcas de tiempo.
SELECT cliente,
       AGE(fecha_hora_inicio, fecha_creacion) AS tiempo_anticipacion
FROM reservas;


-- =====================================================
-- Caso de uso 25
-- Reservas confirmadas, largas (>2h) y futuras
-- =====================================================
-- Lógica: se combinan tres condiciones con AND: estado exacto,
-- duración calculada mayor a un INTERVAL de 2 horas, y fecha
-- posterior al día actual.
SELECT id, cliente, sala, fecha_reserva, fecha_hora_inicio, fecha_hora_fin
FROM reservas
WHERE estado = 'CONFIRMADA'
  AND (fecha_hora_fin - fecha_hora_inicio) > INTERVAL '2 hours'
  AND fecha_reserva > CURRENT_DATE;


-- =====================================================
-- Caso de uso 26
-- Reservas futuras de la Sala A, de la más próxima a la más lejana
-- =====================================================
-- Lógica: se filtra por sala y por inicio posterior al instante
-- actual, ordenando ascendentemente por fecha_hora_inicio.
SELECT id, cliente, sala, fecha_hora_inicio
FROM reservas
WHERE sala = 'Sala A'
  AND fecha_hora_inicio > CURRENT_TIMESTAMP
ORDER BY fecha_hora_inicio ASC;


-- =====================================================
-- Caso de uso 27
-- Reserva futura más cercana (cualquier sala)
-- =====================================================
-- Lógica: se ordenan las reservas futuras ascendentemente por inicio
-- y se limita el resultado a un solo registro con LIMIT 1.
SELECT id, cliente, sala, fecha_hora_inicio
FROM reservas
WHERE fecha_hora_inicio > CURRENT_TIMESTAMP
ORDER BY fecha_hora_inicio ASC
LIMIT 1;


-- =====================================================
-- Caso de uso 28
-- Reserva futura más lejana
-- =====================================================
-- Lógica: mismo filtro de futuras, pero ordenando en forma
-- descendente para que el primer registro sea el más lejano.
SELECT id, cliente, sala, fecha_hora_inicio
FROM reservas
WHERE fecha_hora_inicio > CURRENT_TIMESTAMP
ORDER BY fecha_hora_inicio DESC
LIMIT 1;


-- =====================================================
-- Caso de uso 29
-- Duración promedio de las reservas
-- =====================================================
-- Lógica: AVG aplicado sobre la resta de TIMESTAMPTZ funciona porque
-- PostgreSQL sabe promediar valores de tipo INTERVAL.
SELECT AVG(fecha_hora_fin - fecha_hora_inicio) AS duracion_promedio
FROM reservas;


-- =====================================================
-- Caso de uso 30
-- Duración total de todas las reservas
-- =====================================================
-- Lógica: SUM sobre los INTERVAL de duración acumula el tiempo total
-- reservado.
SELECT SUM(fecha_hora_fin - fecha_hora_inicio) AS duracion_total
FROM reservas;


-- =====================================================
-- Caso de uso 31
-- Cantidad de reservas por día
-- =====================================================
-- Lógica: se agrupa por la columna DATE fecha_reserva y se cuenta
-- cuántos registros hay en cada grupo.
SELECT fecha_reserva AS fecha, COUNT(*) AS cantidad_reservas
FROM reservas
GROUP BY fecha_reserva
ORDER BY fecha_reserva;


-- =====================================================
-- Caso de uso 32
-- Cantidad de reservas por sala en septiembre de 2026
-- =====================================================
-- Lógica: se filtra el rango del mes con BETWEEN y luego se agrupa
-- por sala para contar las reservas de cada una.
SELECT sala, COUNT(*) AS cantidad_reservas
FROM reservas
WHERE fecha_reserva BETWEEN '2026-09-01' AND '2026-09-30'
GROUP BY sala;


-- =====================================================
-- Parte 12. Reto de actualización
-- =====================================================

-- Caso de uso 33
-- Reservas futuras de Sala A: comienzan 1 hora más tarde
-- ---------------------------------------------------
-- Paso 1: SELECT de verificación (qué registros se van a modificar)
SELECT id, cliente, sala, fecha_hora_inicio
FROM reservas
WHERE sala = 'Sala A'
  AND fecha_hora_inicio > CURRENT_TIMESTAMP;

-- Paso 2: UPDATE
-- Lógica: se suma un INTERVAL de 1 hora únicamente a fecha_hora_inicio
-- de las reservas futuras de Sala A, tal como pide el enunciado.
UPDATE reservas
SET fecha_hora_inicio = fecha_hora_inicio + INTERVAL '1 hour'
WHERE sala = 'Sala A'
  AND fecha_hora_inicio > CURRENT_TIMESTAMP;


-- Caso de uso 34
-- Reservas pendientes: extender fin 30 minutos
-- ---------------------------------------------------
-- Paso 1: SELECT de verificación
SELECT id, cliente, sala, fecha_hora_fin
FROM reservas
WHERE estado = 'PENDIENTE';

-- Paso 2: UPDATE
-- Lógica: se suma un INTERVAL de 30 minutos a fecha_hora_fin de todas
-- las reservas en estado PENDIENTE.
UPDATE reservas
SET fecha_hora_fin = fecha_hora_fin + INTERVAL '30 minutes'
WHERE estado = 'PENDIENTE';


-- Caso de uso 35
-- Marcar como FINALIZADA las reservas cuyo fin ya pasó
-- ---------------------------------------------------
-- Paso 1: SELECT de verificación
SELECT id, cliente, sala, fecha_hora_fin, estado
FROM reservas
WHERE fecha_hora_fin < CURRENT_TIMESTAMP
  AND estado <> 'FINALIZADA';

-- Paso 2: UPDATE
-- Lógica: se actualiza el estado solo de las reservas cuyo fin ya es
-- anterior al instante actual y que todavía no están marcadas como
-- FINALIZADA (evita reescrituras innecesarias).
UPDATE reservas
SET estado = 'FINALIZADA'
WHERE fecha_hora_fin < CURRENT_TIMESTAMP
  AND estado <> 'FINALIZADA';


-- =====================================================
-- Parte 13. Reto integrador
-- Reservas prioritarias: CONFIRMADA, duración > 3h,
-- inician dentro de los próximos 15 días
-- =====================================================
-- Lógica: se combinan tres condiciones -> estado exacto, duración
-- calculada (resta de TIMESTAMPTZ) mayor a un INTERVAL de 3 horas, y
-- el inicio debe estar entre ahora y "ahora + 15 días".
SELECT id,
       cliente,
       sala,
       fecha_hora_inicio,
       fecha_hora_fin,
       (fecha_hora_fin - fecha_hora_inicio) AS duracion
FROM reservas
WHERE estado = 'CONFIRMADA'
  AND (fecha_hora_fin - fecha_hora_inicio) > INTERVAL '3 hours'
  AND fecha_hora_inicio BETWEEN CURRENT_TIMESTAMP
                             AND (CURRENT_TIMESTAMP + INTERVAL '15 days');


-- =====================================================
-- Parte 14. Caso de uso avanzado
-- Reporte gerencial de reservas
-- =====================================================
-- Lógica: se arma cada columna solicitada con la función adecuada
-- (TO_CHAR para fecha y hora formateadas, resta de TIMESTAMPTZ para
-- la duración, resta de DATE para los días restantes) y se ordena
-- cronológicamente por fecha_hora_inicio.
SELECT cliente,
       sala,
       TO_CHAR(fecha_hora_inicio, 'DD/MM/YYYY') AS fecha_formateada,
       TO_CHAR(fecha_hora_inicio, 'HH24:MI')    AS hora_inicio,
       (fecha_hora_fin - fecha_hora_inicio)     AS duracion,
       (fecha_reserva - CURRENT_DATE)           AS dias_para_reserva,
       estado
FROM reservas
ORDER BY fecha_hora_inicio;
