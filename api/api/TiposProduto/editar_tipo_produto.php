<?php
require_once '../config02.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: PUT, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$method = $_SERVER['REQUEST_METHOD'];

try {
    if ($method == 'PUT') {
        $input = json_decode(file_get_contents('php://input'), true);
        
        if (!isset($input['id_tipo_produto']) || !isset($input['desc_tipo_produto'])) {
            echo json_encode(['status' => 'error', 'message' => 'Dados incompletos']);
            exit;
        }
        
        $stmt = $pdo->prepare("UPDATE tb_tipo_produto SET desc_tipo_produto = ? WHERE id_tipo_produto = ?");
        $stmt->execute([
            $input['desc_tipo_produto'],
            $input['id_tipo_produto']
        ]);
        
        if ($stmt->rowCount() > 0) {
            echo json_encode(['status' => 'success', 'message' => 'Tipo de produto atualizado com sucesso']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Nenhum tipo de produto encontrado para atualizar']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Método não suportado']);
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Erro no servidor: ' . $e->getMessage()]);
}