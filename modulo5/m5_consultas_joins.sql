-- Pre-entrega Módulo 5: Consultas con JOINs para el proyecto
USE Ventas_Tech_DB;
GO

IF OBJECT_ID('territorios') IS NULL
BEGIN
    CREATE TABLE territorios (
        id_territorio INT         PRIMARY KEY,
        ciudad        VARCHAR(50) NOT NULL,
        region        VARCHAR(50) NOT NULL
    );
    INSERT INTO territorios (id_territorio, ciudad, region) VALUES
      (1, 'Buenos Aires', 'AMBA'),
      (2, 'Córdoba',      'Centro'),
      (3, 'Rosario',      'Centro'),
      (4, 'Mendoza',      'Cuyo'),
      (5, 'Tucumán',      'NOA');
END;
GO

IF COL_LENGTH('clientes', 'id_territorio') IS NULL
    ALTER TABLE clientes ADD id_territorio INT FOREIGN KEY REFERENCES territorios(id_territorio);
GO

UPDATE c
SET c.id_territorio = t.id_territorio
FROM clientes c
INNER JOIN territorios t ON c.ciudad = t.ciudad;
GO

IF NOT EXISTS (SELECT 1 FROM clientes WHERE id_cliente = 6)
    INSERT INTO clientes (id_cliente, nombre, email, ciudad, fecha_registro, id_territorio) VALUES
      (6, 'Sofía Reyes', 'sofia@mail.com',  'Córdoba', '2024-03-20', 2),
      (7, 'Martín Cruz', 'martin@mail.com', 'Mendoza', '2024-03-25', 4);

IF NOT EXISTS (SELECT 1 FROM productos WHERE id_producto = 7)
    INSERT INTO productos (id_producto, nombre_producto, id_categoria, precio, stock, activo) VALUES
      (7, 'Hub USB-C 7 puertos', 2, 45.00, 60, 1);
GO

-- Consulta 1 — Vista base del proyecto (INNER JOIN)
SELECT
    v.id_venta,
    v.fecha_venta,
    c.nombre                       AS cliente,
    c.ciudad,
    t.region,
    p.nombre_producto              AS producto,
    cat.nombre_categoria           AS categoria,
    v.cantidad,
    v.precio_unitario,
    v.cantidad * v.precio_unitario AS total_venta
FROM ventas v
INNER JOIN clientes    c   ON v.id_cliente    = c.id_cliente
INNER JOIN productos   p   ON v.id_producto   = p.id_producto
INNER JOIN categorias  cat ON p.id_categoria  = cat.id_categoria
INNER JOIN territorios t   ON c.id_territorio = t.id_territorio
ORDER BY v.fecha_venta;

-- Consulta 2 — Clientes sin ventas (LEFT JOIN)
SELECT
    c.nombre,
    c.email,
    c.fecha_registro
FROM clientes c
LEFT JOIN ventas v ON c.id_cliente = v.id_cliente
WHERE v.id_venta IS NULL;

-- Consulta 3 — Productos sin ventas (LEFT JOIN)
SELECT
    p.nombre_producto,
    cat.nombre_categoria AS categoria,
    p.precio
FROM productos p
LEFT JOIN ventas     v   ON p.id_producto  = v.id_producto
LEFT JOIN categorias cat ON p.id_categoria = cat.id_categoria
WHERE v.id_venta IS NULL;

-- Consulta 4 — Consolidado por período (UNION ALL)
SELECT periodo, COUNT(*) AS cantidad_ventas, SUM(total) AS total_periodo
FROM (
    SELECT fecha_venta, cantidad * precio_unitario AS total, '1ra mitad (1-10 mar)' AS periodo
    FROM ventas WHERE fecha_venta <= '2024-03-10'
    UNION ALL
    SELECT fecha_venta, cantidad * precio_unitario AS total, '2da mitad (11-31 mar)' AS periodo
    FROM ventas WHERE fecha_venta > '2024-03-10'
) AS consolidado
GROUP BY periodo
ORDER BY periodo;