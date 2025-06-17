<?php
// objects/confeitaria.php
class Confeitaria {
    private $pdo;

    public function __construct($pdo) {
        $this->pdo = $pdo;
    }

    public function readOne($idConfeitaria) {
        $stmt = $this->pdo->prepare("SELECT * FROM tb_confeitaria WHERE id_confeitaria = ?");
        $stmt->execute([$idConfeitaria]);
        return $stmt->fetch();
    }
}
?>