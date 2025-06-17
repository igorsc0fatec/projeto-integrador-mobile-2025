<?php
require_once '../config.php';

header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: PUT, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

$method = $_SERVER['REQUEST_METHOD'];

try {
    if ($method == 'PUT') {
        $input = json_decode(file_get_contents('php://input'), true);

        // Validação dos dados obrigatórios
        $requiredFields = ['id_produto', 'nome_produto', 'desc_produto', 'valor_produto', 'id_tipo_produto'];
        foreach ($requiredFields as $field) {
            if (!isset($input[$field])) {
                echo json_encode(['status' => 'error', 'message' => "Campo obrigatório faltando: $field"]);
                exit;
            }
        }

        // Campos opcionais com valores padrão
        $frete = isset($input['frete']) ? (float)$input['frete'] : 0.00;
        $limite_entrega = isset($input['limite_entrega']) ? (int)$input['limite_entrega'] : 1;
        $produto_ativo = isset($input['produto_ativo']) ? (int)$input['produto_ativo'] : 1;
        $img_produto = isset($input['img_produto']) ? $input['img_produto'] : null;

        // Preparar e executar a atualização usando MySQLi
        $stmt = $conn->prepare("
            UPDATE tb_produto SET 
                nome_produto = ?,
                desc_produto = ?,
                valor_produto = ?,
                frete = ?,
                produto_ativo = ?,
                limite_entrega = ?,
                img_produto = ?,
                id_tipo_produto = ?
            WHERE id_produto = ?
        ");

        $stmt->bind_param(
            "ssddiisii",
            $input['nome_produto'],
            $input['desc_produto'],
            $input['valor_produto'],
            $frete,
            $produto_ativo,
            $limite_entrega,
            $img_produto,
            $input['id_tipo_produto'],
            $input['id_produto']
        );

        $stmt->execute();

        if ($stmt->affected_rows > 0) {
            // Retornar os dados atualizados
            $stmt = $conn->prepare("
                SELECT p.*, tp.desc_tipo_produto 
                FROM tb_produto p
                JOIN tb_tipo_produto tp ON p.id_tipo_produto = tp.id_tipo_produto
                WHERE p.id_produto = ?
            ");
            $stmt->bind_param("i", $input['id_produto']);
            $stmt->execute();
            $result = $stmt->get_result();
            $produtoAtualizado = $result->fetch_assoc();

            echo json_encode([
                'status' => 'success',
                'message' => 'Produto atualizado com sucesso',
                'data' => [
                    'id_produto' => (int)$produtoAtualizado['id_produto'],
                    'nome_produto' => $produtoAtualizado['nome_produto'],
                    'desc_produto' => $produtoAtualizado['desc_produto'],
                    'valor_produto' => (float)$produtoAtualizado['valor_produto'],
                    'frete' => (float)$produtoAtualizado['frete'],
                    'produto_ativo' => (bool)$produtoAtualizado['produto_ativo'],
                    'limite_entrega' => (int)$produtoAtualizado['limite_entrega'],
                    'img_produto' => $produtoAtualizado['img_produto'],
                    'tipo_produto' => $produtoAtualizado['desc_tipo_produto'],
                    'id_tipo_produto' => (int)$produtoAtualizado['id_tipo_produto'],
                    'id_confeitaria' => (int)$produtoAtualizado['id_confeitaria']
                ]
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Nenhum produto encontrado para atualizar ou dados idênticos'
            ]);
        }
    } elseif ($method == 'OPTIONS') {
        // Resposta para requisições OPTIONS (CORS preflight)
        http_response_code(200);
        exit;
    } else {
        http_response_code(405);
        echo json_encode(['status' => 'error', 'message' => 'Método não permitido']);
    }
} catch (Exception $e) {
    http_response_code(500);
    echo json_encode(['status' => 'error', 'message' => 'Erro no servidor: ' . $e->getMessage()]);
}
?>