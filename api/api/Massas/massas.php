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
        $stmt = $conn->prepare("SELECT * FROM tb_massa WHERE id_confeitaria = ?");
        $stmt->bind_param("i", $idConfeitaria);
        $stmt->execute();
        $result = $stmt->get_result();
        
        $massas = [];
        while ($row = $result->fetch_assoc()) {
            $massas[] = [
                'id_massa' => $row['id_massa'],
                'desc_massa' => $row['desc_massa'],
                'valor_por_peso' => (float)$row['valor_por_peso'], // Garante que é float
                'id_confeitaria' => $row['id_confeitaria']
            ];
        }
        
        echo json_encode([
            'status' => 'success',
            'data' => $massas
        ]);
        
    } catch (Exception $e) {
        echo json_encode([
            'status' => 'error',
            'message' => 'Erro ao listar massas: ' . $e->getMessage()
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
        // Converte explicitamente para float
        $valor = (float)$data->valorPorPeso;
        
        $stmt = $conn->prepare("INSERT INTO tb_massa (desc_massa, valor_por_peso, id_confeitaria) VALUES (?, ?, ?)");
        $stmt->bind_param("sdi", $data->descricao, $valor, $data->idConfeitaria);
        
        if ($stmt->execute()) {
            $id = $conn->insert_id;
            
            echo json_encode([
                'status' => 'success',
                'message' => 'Massa cadastrada com sucesso',
                'data' => [
                    'id_massa' => $id,
                    'desc_massa' => $data->descricao,
                    'valor_por_peso' => $valor,
                    'id_confeitaria' => $data->idConfeitaria
                ]
            ]);
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Erro ao cadastrar massa'
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
    global $conn;
    
    $idMassa = isset($_GET['id']) ? intval($_GET['id']) : null;
    
    if (!$idMassa) {
        echo json_encode([
            'status' => 'error',
            'message' => 'ID da massa é obrigatório'
        ]);
        exit;
    }

    try {
        $stmt = $conn->prepare("DELETE FROM tb_massa WHERE id_massa = ?");
        $stmt->bind_param("i", $idMassa);
        
        if ($stmt->execute()) {
            if ($stmt->affected_rows > 0) {
                echo json_encode([
                    'status' => 'success',
                    'message' => 'Massa removida com sucesso'
                ]);
            } else {
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Massa não encontrada'
                ]);
            }
        } else {
            echo json_encode([
                'status' => 'error',
                'message' => 'Erro ao remover massa'
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