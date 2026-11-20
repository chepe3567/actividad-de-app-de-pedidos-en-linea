USE PedidosOnlineDB;
GO

-- Trigger DML AFTER UPDATE: Audita cambios de estado en Pedidos
CREATE OR ALTER TRIGGER dbo.trg_AuditarCambioEstadoPedido
ON Pedidos
AFTER UPDATE
AS
BEGIN
    SET NOCOUNT ON;

    IF UPDATE(EstadoID)
    BEGIN
        INSERT INTO AuditoriaPedidos (PedidoID, EstadoAnterior, EstadoNuevo, UsuarioBD, FechaCambio)
        SELECT
            i.PedidoID,
            d.EstadoID,
            i.EstadoID,
            SUSER_SNAME(),
            SYSDATETIME()
        FROM inserted i
        INNER JOIN deleted d ON i.PedidoID = d.PedidoID
        WHERE i.EstadoID <> d.EstadoID;
    END
END;
GO