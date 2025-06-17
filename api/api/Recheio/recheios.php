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
        $stmt = $conn->prepare("SELECT * FROM tb_recheio WHERE id_confeitaria = ?");
        $stmt->bind_param("i", $idConfeitaria);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $recheios = [];
        while ($row = $result->fetch_assoc()) {
            $recheios[] = [
                'id_recheio' => $row['id_recheio'],
                'desc_recheio' => $row['desc_recheio'],
                'valor_por_peso' => (float)$row['valor_por_peso'],
                'id_confeitaria' => $row['id_confeitaria']
            ];
        }
        
        echo json_encode([
            'status' => 'success',
            'data' => $recheios
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Erro ao listar recheios: ' . $e->getMessage()
        ]);
    }
}

function handlePostRequest() {
    global $conn;
    
    $data = json_decode(file_get_contents("php://input"));

    if (!$data || !isset($data->descricao) || !isset($data->valorPorPeso) || !isset($data->idConfeitaria)) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Dados inválidos ou ausentes'
        ]);
        exit;
    }

    try {
        $valor = (float)$data->valorPorPeso;
        
        $stmt = $conn->prepare("INSERT INTO tb_recheio (desc_recheio, valor_por_peso, id_confeitaria) VALUES (?, ?, ?)");
        $stmt->bind_param("sdi", $data->descricao, $valor, $data->idConfeitaria);
        
        if ($stmt->execute()) {
            $id = $conn->insert_id;
            
            echo json_encode([
                'status' => 'success',
                'message' => 'Recheio cadastrado com sucesso',
                'data' => [
                    'id_recheio' => $id,
                    'desc_recheio' => $data->descricao,
                    'valor_por_peso' => $valor,
                    'id_confeitaria' => $data->idConfeitaria
                ]
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Erro ao cadastrar recheio'
            ]);
        }
    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Erro no servidor: ' . $e->getMessage()
        ]);
    }
}
?>