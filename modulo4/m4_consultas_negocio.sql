SELECT TOP 5
    id_producto,
    SUM(cantidad)                   AS unidades_vendidas,
    SUM(cantidad * precio_unitario) AS total_facturado
FROM ventas
GROUP BY id_producto
ORDER BY total_facturado DESC;

SELECT
    id_cliente,
    COUNT(*)                        AS cantidad_pedidos,
    SUM(cantidad * precio_unitario) AS total_gastado
FROM ventas
GROUP BY id_cliente
HAVING COUNT(*) > 1
ORDER BY total_gastado DESC;

WITH facturacion_producto AS (
    SELECT
        id_producto,
        SUM(cantidad * precio_unitario) AS total_facturado
    FROM ventas
    GROUP BY id_producto
)
SELECT
    id_producto,
    total_facturado,
    CASE
        WHEN total_facturado > (SELECT AVG(total_facturado) FROM facturacion_producto)
            THEN 'Por encima'
        ELSE 'Por debajo'
    END AS comparacion_promedio
FROM facturacion_producto
ORDER BY total_facturado DESC;
-- ==========================================================
-- 1. El producto 1 (Laptop Pro 15) facturó 3.600 de 6.444 en marzo 2024:
--    concentra el 56% de la facturación con solo 3 unidades vendidas.
-- 2. Solo 2 de 6 productos (1 y 3) superan el promedio por producto (1.074);
--    entre ambos suman el 77% de lo facturado: alta dependencia de Computación.
-- 3. Los 5 clientes compraron 2 veces cada uno (100% recurrencia), pero los
--    clientes 1 y 5 explican el 74% del gasto total (2.640 y 2.100).   