USE PedidosOnlineDB;
GO

-- 1. Función Escalar: Calcula el 13% de impuesto sobre un subtotal
CREATE OR ALTER FUNCTION dbo.fn_CalcularImpuesto (@Subtotal DECIMAL(12,2))
RETURNS DECIMAL(12,2)
AS
BEGIN
    RETURN ROUND(@Subtotal * 0.13, 2);
END;
GO

-- 2. Función de Tabla en Línea (TVF): Historial de pedidos por cliente
CREATE OR ALTER FUNCTION dbo.fn_HistorialPedidosCliente (@ClienteID INT)
RETURNS TABLE
AS
RETURN (
    SELECT
        p.PedidoID,
        p.FechaPedido,
        e.NombreEstado AS Estado,
        p.Subtotal,
        p.Impuesto,
        p.Total
    FROM Pedidos p
    INNER JOIN EstadosPedido e ON p.EstadoID = e.EstadoID
    WHERE p.ClienteID = @ClienteID
);
GO