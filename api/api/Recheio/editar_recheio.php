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

        // Validação dos dados
        if (!isset($input['id_recheio']) || !isset($input['desc_recheio']) || !isset($input['valor_por_peso'])) {
            echo json_encode(['status' => 'error', 'message' => 'Dados incompletos']);
            exit;
        }

        $stmt = $pdo->prepare("UPDATE tb_recheio SET desc_recheio = ?, valor_por_peso = ? WHERE id_recheio = ?");
        $stmt->execute([
            $input['desc_recheio'],
            $input['valor_por_peso'],
            $input['id_recheio']
        ]);

        if ($stmt->rowCount() > 0) {
            echo json_encode(['status' => 'success', 'message' => 'Recheio atualizado com sucesso']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Nenhum recheio encontrado para atualizar ou dados iguais']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Método não suportado']);
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Erro no servidor: ' . $e->getMessage()]);
}
?>