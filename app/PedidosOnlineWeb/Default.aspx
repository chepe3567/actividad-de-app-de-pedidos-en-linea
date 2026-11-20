<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Default.aspx.cs" Inherits="PedidosOnlineWeb.Default" %>

<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>Pedidos Online - SQL Server</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 24px; background: #f5f7fa; }
        .card { background: #fff; padding: 18px; margin-bottom: 20px; border-radius: 8px; box-shadow: 0 1px 4px rgba(0,0,0,0.1); }
        .row { margin-bottom: 10px; }
        label { display: inline-block; width: 140px; font-weight: bold; }
        input, select, button { padding: 6px 10px; }
        .msg { font-weight: bold; margin: 12px 0; display: block; color: #0b5394; }
    </style>
</head>
<body>
    <form id="form1" runat="server">
        <h2>Sistema de Pedidos Online (ASP.NET Web Forms + SQL Server)</h2>
        <asp:Label ID="lblMensaje" runat="server" CssClass="msg" />

        <div class="card">
            <h3>1. Registrar Pedido (Consume <code>sp_RegistrarPedidoUnProducto</code>)</h3>
            <div class="row">
                <label>Cliente:</label>
                <asp:DropDownList ID="ddlClientes" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlClientes_SelectedIndexChanged" />
            </div>
            <div class="row">
                <label>Producto:</label>
                <asp:DropDownList ID="ddlProductosPedido" runat="server" />
            </div>
            <div class="row">
                <label>Cantidad:</label>
                <asp:TextBox ID="txtCantidad" runat="server" TextMode="Number" Text="1" />
                <asp:Button ID="btnCrearPedido" runat="server" Text="Crear Pedido" OnClick="btnCrearPedido_Click" />
            </div>

            <h4>Historial del Cliente (Consume <code>fn_HistorialPedidosCliente</code>)</h4>
            <asp:GridView ID="gvHistorial" runat="server" AutoGenerateColumns="true" />

            <h4>Cambiar Estado de Pedido (Dispara <code>trg_AuditarCambioEstadoPedido</code>)</h4>
            <div class="row">
                <label>Pedido ID:</label>
                <asp:TextBox ID="txtPedidoEstadoID" runat="server" TextMode="Number" Width="80px" />
                <label style="width:90px;">Estado:</label>
                <asp:DropDownList ID="ddlEstados" runat="server" />
                <asp:Button ID="btnCambiarEstado" runat="server" Text="Actualizar Estado" OnClick="btnCambiarEstado_Click" />
            </div>
        </div>

        <div class="card">
            <h3>2. CRUD de Productos (Consume <code>sp_GuardarProducto</code> y <code>sp_EliminarProducto</code>)</h3>
            <asp:HiddenField ID="hfProductoID" runat="server" Value="0" />
            <div class="row">
                <label>Categoría:</label>
                <asp:DropDownList ID="ddlCategorias" runat="server" />
                <label style="width:70px;">SKU:</label>
                <asp:TextBox ID="txtSKU" runat="server" Width="110px" />
            </div>
            <div class="row">
                <label>Nombre:</label>
                <asp:TextBox ID="txtNombreProducto" runat="server" Width="220px" />
                <label style="width:70px;">Precio:</label>
                <asp:TextBox ID="txtPrecio" runat="server" Width="90px" />
                <label style="width:70px;">Stock:</label>
                <asp:TextBox ID="txtStock" runat="server" TextMode="Number" Width="80px" />
            </div>
            <div class="row">
                <asp:Button ID="btnGuardarProducto" runat="server" Text="Guardar Producto" OnClick="btnGuardarProducto_Click" />
                <asp:Button ID="btnLimpiarProducto" runat="server" Text="Limpiar" OnClick="btnLimpiarProducto_Click" />
            </div>

            <asp:GridView ID="gvProductos" runat="server" AutoGenerateColumns="false" DataKeyNames="ProductoID"
                OnSelectedIndexChanged="gvProductos_SelectedIndexChanged" OnRowDeleting="gvProductos_RowDeleting">
                <Columns>
                    <asp:BoundField DataField="ProductoID" HeaderText="ID" />
                    <asp:BoundField DataField="SKU" HeaderText="SKU" />
                    <asp:BoundField DataField="NombreProducto" HeaderText="Producto" />
                    <asp:BoundField DataField="NombreCategoria" HeaderText="Categoría" />
                    <asp:BoundField DataField="PrecioUnitario" HeaderText="Precio" DataFormatString="{0:C}" />
                    <asp:BoundField DataField="Stock" HeaderText="Stock" />
                    <asp:CommandField ShowSelectButton="true" SelectText="Editar" />
                    <asp:CommandField ShowDeleteButton="true" DeleteText="Eliminar" />
                </Columns>
            </asp:GridView>
        </div>
    </form>
</body>
</html>