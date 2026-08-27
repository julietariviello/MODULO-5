-- ══════════════════════════════════════════
-- RetailPro — Módulo 5: Consultas con JOINs
-- Autor: Julieta Riviello
-- Fecha: 27-08-2026
-- ══════════════════════════════════════════

USE Ventas_Tech_DB;

-- ── CONSULTA 1: Vista base del proyecto (INNER JOIN) ──────────────────
-- Pregunta de negocio: Vista unificada de ventas para alimentar Power BI con detalles de clientes, productos, categorías y región/segmento/canal.

SELECT 
    v.fecha_venta AS fecha,
    c.nombre AS nombre_cliente,
    'Consumo Final' AS segmento,                  -- Segmento genérico/calculado
    c.ciudad AS region,                           -- Ciudad utilizada como ubicación/región
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    v.cantidad,
    v.precio_unitario,
    (v.cantidad * v.precio_unitario) AS total_venta,
    'Online' AS canal                             -- Canal por defecto
FROM ventas v
INNER JOIN clientes c ON v.id_cliente = c.id_cliente
INNER JOIN productos p ON v.id_producto = p.id_producto
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
ORDER BY v.fecha_venta;


-- ── CONSULTA 2: Clientes sin ventas (LEFT JOIN) ───────────────────────
-- Pregunta de negocio: Identificar clientes registrados que aún no han realizado compras.

SELECT 
    c.nombre AS nombre_cliente,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;


-- ── CONSULTA 3: Productos sin ventas (LEFT JOIN) ──────────────────────
-- Pregunta de negocio: Identificar artículos del catálogo sin movimiento comercial.

SELECT 
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
INNER JOIN categorias cat ON p.id_categoria = cat.id_categoria
LEFT JOIN ventas v ON p.id_producto = v.id_producto
WHERE v.id_venta IS NULL;


-- ── CONSULTA 4: Consolidado por canal (UNION ALL) ─────────────────────
-- Pregunta de negocio: Combinar las ventas por origen (Online vs. Presencial) y calcular el total facturado acumulado por cada canal.

WITH ventas_online AS (
    -- Simulación de origen Online (Ventas con id_venta impar)
    SELECT 
        id_venta,
        cantidad,
        precio_unitario,
        'Online' AS canal
    FROM ventas
    WHERE MOD(id_venta, 2) <> 0
),
ventas_presencial AS (
    -- Simulación de origen Presencial (Ventas con id_venta par)
    SELECT 
        id_venta,
        cantidad,
        precio_unitario,
        'Presencial' AS canal
    FROM ventas
    WHERE MOD(id_venta, 2) = 0
),
ventas_consolidadas AS (
    SELECT * FROM ventas_online
    UNION ALL
    SELECT * FROM ventas_presencial
)
SELECT 
    canal,
    COUNT(*) AS cantidad_transacciones,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas_consolidadas
GROUP BY canal;

