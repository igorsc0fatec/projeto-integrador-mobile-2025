<?php
// api/Confeitaria/confeitaria.php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");

require_once '../config.php';

$method = $_SERVER['REQUEST_METHOD'];

switch ($method) {
    case 'GET':
        // Buscar dados da confeitaria
        if (isset($_GET['id_confeitaria'])) {
            $idConfeitaria = $_GET['id_confeitaria'];
            
            $stmt = $conn->prepare("SELECT * FROM tb_confeitaria WHERE id_confeitaria = ?");
            $stmt->bind_param("i", $idConfeitaria);
            $stmt->execute();
            $result = $stmt->get_result();
            
            if ($result->num_rows > 0) {
                $confeitaria = $result->fetch_assoc();
                echo json_encode([
                    'status' => 'success',
                    'data' => $confeitaria
                ]);
            } else {
                echo json_encode([
                    'status' => 'error',
                    'message' => 'Confeitaria não encontrada'
                ]);
            }
        }
        break;
        
    default:
        http_response_code(405);
        echo json_encode(['status' => 'error', 'message' => 'Método não permitido']);
        break;
}
?>