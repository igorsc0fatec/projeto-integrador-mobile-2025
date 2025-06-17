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
        if (!isset($input['id_formato']) || !isset($input['desc_formato']) || !isset($input['valor_por_peso'])) {
            echo json_encode(['status' => 'error', 'message' => 'Dados incompletos']);
            exit;
        }

        $stmt = $pdo->prepare("UPDATE tb_formato SET desc_formato = ?, valor_por_peso = ? WHERE id_formato = ?");
        $stmt->execute([
            $input['desc_formato'],
            $input['valor_por_peso'],
            $input['id_formato']
        ]);

        if ($stmt->rowCount() > 0) {
            echo json_encode(['status' => 'success', 'message' => 'Formato atualizado com sucesso']);
        } else {
            echo json_encode(['status' => 'error', 'message' => 'Nenhum formato encontrado para atualizar ou dados iguais']);
        }
    } else {
        echo json_encode(['status' => 'error', 'message' => 'Método não suportado']);
    }
} catch (PDOException $e) {
    echo json_encode(['status' => 'error', 'message' => 'Erro no servidor: ' . $e->getMessage()]);
}
?>
