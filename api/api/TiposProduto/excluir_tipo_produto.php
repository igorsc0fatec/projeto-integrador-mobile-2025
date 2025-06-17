<?php
// Força o cabeçalho para JSON
header('Content-Type: application/json; charset=utf-8');

// Inclui o arquivo de configuração
require __DIR__ . '../../config02.php';

try {
    // Permite CORS para desenvolvimento (remova em produção)
    header("Access-Control-Allow-Origin: *");
    header("Access-Control-Allow-Methods: DELETE, GET, OPTIONS");
    header("Access-Control-Allow-Headers: Content-Type");

    // Verifica o método HTTP
    $method = $_SERVER['REQUEST_METHOD'];
    if (!in_array($method, ['DELETE', 'GET', 'OPTIONS'])) {
        throw new Exception("Método não permitido", 405);
    }

    // Se for OPTIONS (pré-flight do CORS), retorna OK
    if ($method === 'OPTIONS') {
        http_response_code(200);
        exit;
    }

    // Pega o ID
    $id = isset($_GET['id']) ? (int)$_GET['id'] : null;

    if (!$id || $id <= 0) {
        throw new Exception("ID não fornecido ou inválido", 400);
    }

    // Verifica se a conexão PDO existe
    if (!isset($pdo)) {
        throw new Exception("Erro de conexão com o banco de dados", 500);
    }

    // Verifica se o tipo de produto existe
    $stmtCheck = $pdo->prepare("SELECT id_tipo_produto FROM tb_tipo_produto WHERE id_tipo_produto = ?");
    $stmtCheck->execute([$id]);
    
    if ($stmtCheck->rowCount() === 0) {
        throw new Exception("Tipo de produto não encontrado", 404);
    }

    // Exclui o tipo de produto
    $stmt = $pdo->prepare("DELETE FROM tb_tipo_produto WHERE id_tipo_produto = ?");
    $success = $stmt->execute([$id]);

    if ($success) {
        http_response_code(200);
        echo json_encode([
            'status' => 'success', 
            'message' => 'Tipo de produto excluído com sucesso',
            'data' => ['id' => $id]
        ]);
    } else {
        throw new Exception("Falha ao excluir tipo de produto", 500);
    }

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        'status' => 'error',
        'message' => 'Erro no banco de dados',
        'error_details' => $e->getMessage()
    ]);
} catch (Exception $e) {
    http_response_code($e->getCode() ?: 500);
    echo json_encode([
        'status' => 'error',
        'message' => $e->getMessage(),
        'error_code' => $e->getCode()
    ]);
}

// Garante que nada mais será enviado
exit;
?>