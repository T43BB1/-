<?php
session_start();
error_reporting(E_ALL);
ini_set('display_errors', 1);

/*
// 허용된 IP 대역 설정
$allowed_ips = [
    '203.0.113.0/24', // 예: 관리자 IP 대역
    '192.0.2.0/24'    // 추가로 허용할 IP 대역
];

// 클라이언트 IP 가져오기
$client_ip = $_SERVER['REMOTE_ADDR'];

// IP 허용 검사 함수
function is_ip_allowed($ip, $allowed_ips) {
    foreach ($allowed_ips as $allowed_ip) {
        if (strpos($allowed_ip, '/') !== false) {
            // CIDR 대역 확인
            list($subnet, $mask) = explode('/', $allowed_ip);
            $mask = ~((1 << (32 - $mask)) - 1);
            if ((ip2long($ip) & $mask) == (ip2long($subnet) & $mask)) {
                return true;
            }
        } elseif ($ip === $allowed_ip) {
            // 단일 IP 확인
            return true;
        }
    }
    return false;
}

// 허용되지 않은 IP 차단
if (!is_ip_allowed($client_ip, $allowed_ips)) {
    http_response_code(403);
    echo "Access Denied: Your IP address ($client_ip) is not authorized.";
    exit();
}


 */

// 데이터베이스 연결 설정
$host = 'localhost';
$db_user = 'test_user';
$db_password = 'test_password';
$db_name = 'collabtool';

// MySQL 연결
$conn = new mysqli($host, $db_user, $db_password, $db_name);

// 연결 오류 처리
if ($conn->connect_error) {
    die("Database connection failed: " . $conn->connect_error);
}

// 로그인 처리
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'];
    $password = $_POST['password'];

    // SQL 인젝션 방지
    $stmt = $conn->prepare("SELECT id, username, password FROM users WHERE email = ?");
    $stmt->bind_param("s", $email);
    $stmt->execute();
    $stmt->store_result();

    // 사용자 확인
    if ($stmt->num_rows > 0) {
        $stmt->bind_result($user_id, $username, $hashed_password);
        $stmt->fetch();

        // 비밀번호 검증
        if (password_verify($password, $hashed_password)) {
            // 세션 생성
            $_SESSION['user_id'] = $user_id;
            $_SESSION['username'] = $username;
            header("Location: project.php"); // 로그인 성공 시 프로젝트 페이지로 이동
            exit();
        } else {
            $error = "Invalid email or password.";
        }
    } else {
        $error = "Invalid email or password.";
    }
    $stmt->close();
}

$conn->close();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 0; display: flex; justify-content: center; align-items: center; height: 100vh; background-color: #f4f4f9; }
        .container { width: 300px; padding: 20px; background: white; box-shadow: 0 0 10px rgba(0,0,0,0.1); border-radius: 5px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; }
        .form-group input { width: 100%; padding: 8px; box-sizing: border-box; }
        .error { color: red; margin-bottom: 15px; }
        .btn { width: 100%; padding: 10px; background: #007bff; color: white; border: none; border-radius: 5px; cursor: pointer; }
        .btn:hover { background: #0056b3; }
    </style>
</head>
<body>
<div class="container">
    <h2>Login</h2>
    <?php if (isset($error)): ?>
        <p class="error"><?= htmlspecialchars($error) ?></p>
    <?php endif; ?>
    <form method="POST">
        <div class="form-group">
            <label for="email">Email:</label>
            <input type="email" id="email" name="email" required>
        </div>
        <div class="form-group">
            <label for="password">Password:</label>
            <input type="password" id="password" name="password" required>
        </div>
        <button type="submit" class="btn">Login</button>
    </form>
</div>
</body>
</html>

