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

        if (!isset($input['id_massa']) || !isset($input['desc_massa']) || !isset($input['valor_por_peso'])) {
            echo json_encode(['status' => 'error', 'message' => 'Dados incompletos']);
            exit;
        }

        $stmt = $pdo->prepare("UPDATE tb_massa SET desc_massa = ?, valor_por_peso = ? WHERE id_massa = ?");
        $stmt->execute([
            $input['desc_massa'],
            $input['valor_por_peso'],
            $input['id_massa']
        ]);

        if ($stmt->rowCount() > 0) {
            echo json_encode(['status' => 'success', 'message' => 'Massa atualizada com sucesso']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Nenhuma massa encontrada para atualizar']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Método não suportado']);
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Erro no servidor: ' . $e->getMessage()]);
}
