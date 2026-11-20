USE PedidosOnlineDB;
GO

-- 1. Registrar pedido con transacción, validación de stock y descuento de inventario
CREATE OR ALTER PROCEDURE dbo.sp_RegistrarPedidoUnProducto
    @ClienteID INT,
    @ProductoID INT,
    @Cantidad INT,
    @NuevoPedidoID INT OUTPUT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @StockActual INT, @Precio DECIMAL(10,2);
        DECLARE @Subtotal DECIMAL(12,2), @Impuesto DECIMAL(12,2), @Total DECIMAL(12,2);

        SELECT @StockActual = Stock, @Precio = PrecioUnitario
        FROM Productos WITH (UPDLOCK)
        WHERE ProductoID = @ProductoID;

        IF @StockActual IS NULL
            THROW 50001, 'El producto especificado no existe.', 1;

        IF @Cantidad <= 0
            THROW 50002, 'La cantidad debe ser mayor a cero.', 1;

        IF @StockActual < @Cantidad
            THROW 50003, 'Stock insuficiente para completar el pedido.', 1;

        SET @Subtotal = @Precio * @Cantidad;
        SET @Impuesto = dbo.fn_CalcularImpuesto(@Subtotal);
        SET @Total = @Subtotal + @Impuesto;

        INSERT INTO Pedidos (ClienteID, EstadoID, Subtotal, Impuesto, Total)
        VALUES (@ClienteID, 1, @Subtotal, @Impuesto, @Total);

        SET @NuevoPedidoID = SCOPE_IDENTITY();

        INSERT INTO DetallePedido (PedidoID, ProductoID, Cantidad, PrecioHistorico)
        VALUES (@NuevoPedidoID, @ProductoID, @Cantidad, @Precio);

        UPDATE Productos
        SET Stock = Stock - @Cantidad
        WHERE ProductoID = @ProductoID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

-- 2. Actualizar estado de un pedido (dispara trg_AuditarCambioEstadoPedido)
CREATE OR ALTER PROCEDURE dbo.sp_ActualizarEstadoPedido
    @PedidoID INT,
    @NuevoEstadoID TINYINT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF NOT EXISTS (SELECT 1 FROM Pedidos WHERE PedidoID = @PedidoID)
            THROW 50004, 'El pedido no existe.', 1;

        IF NOT EXISTS (SELECT 1 FROM EstadosPedido WHERE EstadoID = @NuevoEstadoID)
            THROW 50005, 'El estado especificado no es válido.', 1;

        UPDATE Pedidos
        SET EstadoID = @NuevoEstadoID
        WHERE PedidoID = @PedidoID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

-- 3. Insertar o actualizar producto
CREATE OR ALTER PROCEDURE dbo.sp_GuardarProducto
    @ProductoID INT = NULL,
    @CategoriaID INT,
    @SKU VARCHAR(30),
    @NombreProducto NVARCHAR(150),
    @PrecioUnitario DECIMAL(10,2),
    @Stock INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF @ProductoID IS NULL OR @ProductoID = 0
        BEGIN
            INSERT INTO Productos (CategoriaID, SKU, NombreProducto, PrecioUnitario, Stock)
            VALUES (@CategoriaID, @SKU, @NombreProducto, @PrecioUnitario, @Stock);
        END
        ELSE
        BEGIN
            UPDATE Productos
            SET CategoriaID = @CategoriaID,
                SKU = @SKU,
                NombreProducto = @NombreProducto,
                PrecioUnitario = @PrecioUnitario,
                Stock = @Stock
            WHERE ProductoID = @ProductoID;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO

-- 4. Eliminar producto si no tiene pedidos asociados
CREATE OR ALTER PROCEDURE dbo.sp_EliminarProducto
    @ProductoID INT
AS
BEGIN
    SET NOCOUNT ON;
    BEGIN TRY
        BEGIN TRANSACTION;

        IF EXISTS (SELECT 1 FROM DetallePedido WHERE ProductoID = @ProductoID)
            THROW 50006, 'No se puede eliminar un producto que ya tiene pedidos asociados.', 1;

        DELETE FROM Productos WHERE ProductoID = @ProductoID;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;

        THROW;
    END CATCH
END;
GO