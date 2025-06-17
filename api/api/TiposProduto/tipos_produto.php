<?php
header("Content-Type: application/json");
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Access-Control-Allow-Headers: Content-Type");

include '../config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        handleGetRequest();
        break;
    case 'POST':
        handlePostRequest();
        break;
    case 'DELETE':
        handleDeleteRequest();
        break;
    default:
        echo json_encode([
            'status' => 'error',
            'message' => 'Método não permitido'
        ]);
        exit;
}

function handleGetRequest() {
    global $conn;
    
    $idConfeitaria = isset($_GET['id_confeitaria']) ? intval($_GET['id_confeitaria']) : null;
    
    if (!$idConfeitaria) {
        echo json_encode([
            'status' => 'error',
            'message' => 'ID da confeitaria é obrigatório'
        ]);
        exit;
    }

    try {
        $stmt = $conn->prepare("SELECT * FROM tb_tipo_produto WHERE id_confeitaria = ?");
        $stmt->bind_param("i", $idConfeitaria);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $tiposProduto = [];
        while ($row = $result->fetch_assoc()) {
            $tiposProduto[] = [
                'id_tipo_produto' => $row['id_tipo_produto'],
                'desc_tipo_produto' => $row['desc_tipo_produto'],
                'id_confeitaria' => $row['id_confeitaria']
            ];
        }
        
        echo json_encode([
            'status' => 'success',
            'data' => $tiposProduto
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Erro ao listar tipos de produto: ' . $e->getMessage()
        ]);
    }
}

function handlePostRequest() {
    global $conn;
    
    $data = json_decode(file_get_contents("php://input"));

    if (!$data || !isset($data->descricao) || !isset($data->idConfeitaria)) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Dados inválidos ou ausentes'
        ]);
        exit;
    }

    try {
        $stmt = $conn->prepare("INSERT INTO tb_tipo_produto (desc_tipo_produto, id_confeitaria) VALUES (?, ?)");
        $stmt->bind_param("si", $data->descricao, $data->idConfeitaria);
        
        if ($stmt->execute()) {
            $id = $conn->insert_id;
            
            echo json_encode([
                'status' => 'success',
                'message' => 'Tipo de produto cadastrado com sucesso',
                'data' => [
                    'id_tipo_produto' => $id,
                    'desc_tipo_produto' => $data->descricao,
                    'id_confeitaria' => $data->idConfeitaria
                ]
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Erro ao cadastrar tipo de produto'
            ]);
        }
    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Erro no servidor: ' . $e->getMessage()
        ]);
    }
}

function handleDeleteRequest() {
    // Implementação do DELETE se necessário
    echo json_encode([
        'status' => 'error',
        'message' => 'Método DELETE não implementado'
    ]);
}
?>