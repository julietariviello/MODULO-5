-- ══════════════════════════════════════════
-- RetailPro — Módulo 4: Consultas SQL de Negocio
-- Autor: Julieta Riviello
-- Fecha: 26-08-2026
-- ══════════════════════════════════════════

-- ── CONSULTA 1: Resumen ejecutivo mensual ──────────────────────────

SELECT 
    EXTRACT(MONTH FROM fecha_venta) AS mes,
    SUM(cantidad * precio_unitario) AS total_facturado,
    COUNT(*) AS cantidad_pedidos,
    AVG(cantidad * precio_unitario) AS ticket_promedio
FROM ventas
GROUP BY EXTRACT(MONTH FROM fecha_venta)
ORDER BY mes;


-- ── CONSULTA 2: Ranking de productos (Top 5) ──────────────────────────

SELECT 
    id_producto,
    SUM(cantidad) AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC
LIMIT 5;


-- ── CONSULTA 3: Clientes recurrentes ──────────────────────────

SELECT 
    id_cliente,
    COUNT(*) AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;


-- ── CONSULTA 4: Meses por encima/por debajo del promedio ──────────────────────────

WITH facturacion_mensual AS (
    SELECT 
        EXTRACT(MONTH FROM fecha_venta) AS mes,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY EXTRACT(MONTH FROM fecha_venta)
)
SELECT 
    mes,
    total_facturado,
    CASE 
        WHEN total_facturado >= (SELECT AVG(total_facturado) FROM facturacion_mensual) THEN 'Por encima'
        ELSE 'Por debajo'
    END AS desempenio_mensual
FROM facturacion_mensual;


-- ══════════════════════════════════════════
-- ── BLOQUE DE CIERRE: Hallazgos de Negocio ──────────────────────────
-- ══════════════════════════════════════════

-- HALLAZGOS Y OBSERVACIONES CLAVE:

-- 1. Alta concentración de ingresos en el producto de mayor valor (id_producto = 1):
-- El producto 1 lidera el ranking de facturación con $3,600.00, lo que representa más del 55.8% de los ingresos totales de la empresa ($6,444.00), habiendo vendido únicamente 3 unidades en el periodo.

-- 2. Buena tasa de recurrencia en la base de clientes:
-- El 100% de los clientes registrados (los 5 clientes) son recurrentes, ya que todos realizaron exactamente 2 pedidos. Los clientes de mayor valor comercial son el id_cliente = 1 ($2,640.00 gastados) y el id_cliente = 5 ($2,100.00 gastados).

-- 3. Divergencia entre volumen físico y volumen monetario (id_producto = 2):
-- El id_producto = 2 es el líder en unidades vendidas (13 unidades), pero ocupa el 5.° puesto en facturación con solo $364.00. Funciona como un producto gancho de alta rotación pero con bajo impacto en la caja total.
