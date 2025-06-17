<?php
// dashboard.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

// Desativa a exibição de erros HTML
ini_set('display_errors', 0);
error_reporting(E_ALL);

require_once 'config.php';

try {
    // Verifica se o ID da confeitaria foi passado
    if (!isset($_GET['id_confeitaria'])) {
        throw new Exception("ID da confeitaria não fornecido", 400);
    }

    $idConfeitaria = $_GET['id_confeitaria'];

    // Valida o ID
    if (!is_numeric($idConfeitaria)) {
        throw new Exception("ID da confeitaria inválido", 400);
    }

    // 1. Obter dados de vendas totais e número de pedidos
    $queryTotalSales = "SELECT 
                        COALESCE(SUM(p.valor_total), 0) as total_vendas, 
                        COALESCE(COUNT(p.id_pedido), 0) as total_pedidos
                        FROM tb_pedido p
                        WHERE p.id_pedido IN (
                            SELECT ip.id_pedido 
                            FROM tb_itens_pedido ip
                            JOIN tb_produto pr ON ip.id_produto = pr.id_produto
                            WHERE pr.id_confeitaria = :id_confeitaria
                        )";
    
    $stmt = $pdo->prepare($queryTotalSales);
    $stmt->bindParam(':id_confeitaria', $idConfeitaria, PDO::PARAM_INT);
    $stmt->execute();
    $salesData = $stmt->fetch(PDO::FETCH_ASSOC);
    
    $totalSales = (float)$salesData['total_vendas'];
    $totalOrders = (int)$salesData['total_pedidos'];
    $avgTicket = $totalOrders > 0 ? $totalSales / $totalOrders : 0;
    
    // 2. Obter produtos mais vendidos
    $queryTopProducts = "SELECT 
                        pr.nome_produto as name, 
                        COALESCE(SUM(ip.quantidade), 0) as sales, 
                        COALESCE(pr.valor_produto, 0) as price
                        FROM tb_itens_pedido ip
                        JOIN tb_produto pr ON ip.id_produto = pr.id_produto
                        JOIN tb_pedido p ON ip.id_pedido = p.id_pedido
                        WHERE pr.id_confeitaria = :id_confeitaria
                        GROUP BY pr.id_produto 
                        ORDER BY sales DESC 
                        LIMIT 5";
    
    $stmt = $pdo->prepare($queryTopProducts);
    $stmt->bindParam(':id_confeitaria', $idConfeitaria, PDO::PARAM_INT);
    $stmt->execute();
    $topProducts = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // 3. Obter pedidos recentes
    $queryRecentRequests = "SELECT 
                           c.nome_cliente as client, 
                           DATE_FORMAT(p.data_pedido, '%Y-%m-%d') as date, 
                           COALESCE(p.valor_total, 0) as total, 
                           COALESCE(p.status, 'Desconhecido') as status
                           FROM tb_pedido p
                           JOIN tb_cliente c ON p.id_cliente = c.id_cliente
                           WHERE p.id_pedido IN (
                               SELECT ip.id_pedido 
                               FROM tb_itens_pedido ip
                               JOIN tb_produto pr ON ip.id_produto = pr.id_produto
                               WHERE pr.id_confeitaria = :id_confeitaria
                           )
                           ORDER BY p.data_pedido DESC 
                           LIMIT 5";
    
    $stmt = $pdo->prepare($queryRecentRequests);
    $stmt->bindParam(':id_confeitaria', $idConfeitaria, PDO::PARAM_INT);
    $stmt->execute();
    $recentRequests = $stmt->fetchAll(PDO::FETCH_ASSOC);
    
    // Montar resposta
    $response = array(
        "status" => "success",
        "data" => array(
            "totalSales" => $totalSales,
            "totalOrders" => $totalOrders,
            "avgTicket" => $avgTicket,
            "topProducts" => $topProducts,
            "recentRequests" => $recentRequests
        )
    );
    
    echo json_encode($response);
    
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(array(
        "status" => "error",
        "message" => "Erro no banco de dados: " . $e->getMessage()
    ));
} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode(array(
        "status" => "error",
        "message" => $e->getMessage()
    ));
}
?>