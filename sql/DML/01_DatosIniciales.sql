USE PedidosOnlineDB;
GO

IF NOT EXISTS (SELECT 1 FROM EstadosPedido)
BEGIN
    INSERT INTO EstadosPedido (NombreEstado) VALUES
    ('Pendiente'), ('Pagado'), ('Enviado'), ('Entregado'), ('Cancelado');
END;

IF NOT EXISTS (SELECT 1 FROM Categorias)
BEGIN
    INSERT INTO Categorias (NombreCategoria, Activo) VALUES
    ('Electrónica', 1), ('Accesorios', 1), ('Periféricos', 1);
END;

IF NOT EXISTS (SELECT 1 FROM Productos)
BEGIN
    INSERT INTO Productos (CategoriaID, SKU, NombreProducto, PrecioUnitario, Stock) VALUES
    (1, 'LAP-001', 'Laptop Gamer 15"', 950.00, 10),
    (3, 'MOU-002', 'Mouse Inalámbrico Pro', 35.50, 40),
    (3, 'TEC-003', 'Teclado Mecánico RGB', 75.00, 25);
END;

IF NOT EXISTS (SELECT 1 FROM Clientes)
BEGIN
    INSERT INTO Clientes (NombreCompleto, Correo, Telefono, DireccionEnvio) VALUES
    ('Carlos Mendoza', 'carlos.mendoza@email.com', '7777-1234', 'San Salvador, Col. Escalón'),
    ('Ana Sofía Rivas', 'ana.rivas@email.com', '7888-5678', 'Santa Tecla, Residencial Loma Linda');
END;
GO