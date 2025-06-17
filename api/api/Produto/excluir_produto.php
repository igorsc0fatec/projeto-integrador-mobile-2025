<?php
// Força o cabeçalho para JSON
header('Content-Type: application/json; charset=utf-8');

// Inclui o arquivo de configuração
require __DIR__ . '../../config02.php';

try {
    // Configurações CORS (ajuste para produção)
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: DELETE, GET, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type");

    // Verifica o método HTTP
    $method = $_SERVER['REQUEST_METHOD'];
    if (!in_array($method, ['DELETE', 'GET', 'OPTIONS'])) {
        throw new Exception("Método não permitido", 405);
    }

    // Responde a requisições OPTIONS (pré-flight CORS)
    if ($method === 'OPTIONS') {
        http_response_code(200);
        exit;
    }

    // Obtém o ID do produto a ser excluído
    $id = isset($_GET['id']) ? (int)$_GET['id'] : null;

    // Validação do ID
    if (!$id || $id <= 0) {
        throw new Exception("ID do produto não fornecido ou inválido", 400);
    }

    // Verifica a conexão com o banco de dados
    if (!isset($pdo)) {
        throw new Exception("Erro de conexão com o banco de dados", 500);
    }

    // Verifica se o produto existe antes de excluir
    $stmtCheck = $pdo->prepare("SELECT id_produto FROM tb_produto WHERE id_produto = ?");
    $stmtCheck->execute([$id]);
    
    if ($stmtCheck->rowCount() === 0) {
        throw new Exception("Produto não encontrado", 404);
    }

    // Verifica se há pedidos associados ao produto (opcional - para integridade referencial)
    $stmtCheckOrders = $pdo->prepare("SELECT id_itens_pedido FROM tb_itens_pedido WHERE id_produto = ? LIMIT 1");
    $stmtCheckOrders->execute([$id]);
    
    if ($stmtCheckOrders->rowCount() > 0) {
        throw new Exception("Não é possível excluir - existem pedidos associados a este produto", 409);
    }

    // Exclui o produto
    $stmt = $pdo->prepare("DELETE FROM tb_produto WHERE id_produto = ?");
    $success = $stmt->execute([$id]);

    if ($success) {
        http_response_code(200);
        echo json_encode([
            'status' => 'success', 
            'message' => 'Produto excluído com sucesso',
            'data' => ['id_produto' => $id]
        ]);
    } else {
        throw new Exception("Falha ao excluir o produto", 500);
    }

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Erro no banco de dados',
        'error_details' => $e->getMessage()
    ]);
} catch (Exception $e) {
    $statusCode = $e->getCode() ?: 500;
    http_response_code($statusCode);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage(),
        'error_code' => $statusCode
    ]);
}

// Encerra a execução
exit;
?>