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
        if (!isset($input['id_decoracao']) || !isset($input['desc_decoracao']) || !isset($input['valor_por_peso'])) {
            echo json_encode(['status' => 'error', 'message' => 'Dados incompletos']);
            exit;
        }

        $stmt = $pdo->prepare("UPDATE tb_decoracao SET desc_decoracao = ?, valor_por_peso = ? WHERE id_decoracao = ?");
        $stmt->execute([
            $input['desc_decoracao'],
            $input['valor_por_peso'],
            $input['id_decoracao']
        ]);

        if ($stmt->rowCount() > 0) {
            echo json_encode(['status' => 'success', 'message' => 'Decoração atualizada com sucesso']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Nenhuma decoração encontrada para atualizar ou dados iguais']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Método não suportado']);
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Erro no servidor: ' . $e->getMessage()]);
}
?>
