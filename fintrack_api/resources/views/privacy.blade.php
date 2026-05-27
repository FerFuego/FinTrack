<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Política de Privacidad — FinTrack</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --background: #0A0E1A;
            --surface: #141928;
            --border: #2a3350;
            --primary: #6C63FF;
            --text-primary: #FFFFFF;
            --text-secondary: #B0BEC5;
            --text-muted: #607D8B;
        }

        body {
            font-family: 'Inter', sans-serif;
            background-color: var(--background);
            color: var(--text-primary);
            margin: 0;
            padding: 0;
            line-height: 1.6;
        }

        .container {
            max-width: 800px;
            margin: 0 auto;
            padding: 40px 20px;
        }

        header {
            text-align: center;
            margin-bottom: 50px;
            border-bottom: 1px solid var(--border);
            padding-bottom: 30px;
        }

        .logo {
            font-size: 32px;
            font-weight: 700;
            letter-spacing: -0.5px;
            background: linear-gradient(135deg, #6C63FF 0%, #9C27B0 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            margin-bottom: 10px;
        }

        h1 {
            font-size: 28px;
            font-weight: 700;
            margin-top: 0;
        }

        h2 {
            font-size: 20px;
            font-weight: 600;
            color: var(--primary);
            margin-top: 40px;
            margin-bottom: 15px;
            border-left: 4px solid var(--primary);
            padding-left: 12px;
        }

        p, li {
            color: var(--text-secondary);
            font-size: 15px;
        }

        ul {
            padding-left: 20px;
        }

        li {
            margin-bottom: 10px;
        }

        .highlight-box {
            background-color: var(--surface);
            border: 1px solid var(--border);
            border-radius: 16px;
            padding: 24px;
            margin: 30px 0;
        }

        .highlight-box p {
            margin: 0;
            color: var(--text-primary);
            font-weight: 500;
        }

        footer {
            margin-top: 60px;
            text-align: center;
            border-top: 1px solid var(--border);
            padding-top: 30px;
            color: var(--text-muted);
            font-size: 13px;
        }

        .btn {
            display: inline-block;
            background-color: var(--primary);
            color: #FFFFFF;
            text-decoration: none;
            padding: 12px 24px;
            border-radius: 10px;
            font-weight: 600;
            font-size: 14px;
            margin-top: 20px;
            transition: opacity 0.2s;
        }

        .btn:hover {
            opacity: 0.9;
        }
    </style>
</head>
<body>

<div class="container">
    <header>
        <div class="logo">FinTrack</div>
        <h1>Reglas de Confianza y Política de Privacidad</h1>
        <p style="color: var(--text-muted); margin-top: 5px;">Última actualización: 26 de Mayo, 2026</p>
    </header>

    <div class="highlight-box">
        <p>🛡️ FinTrack está construida sobre principios absolutos de privacidad y soberanía de los datos. No rastreamos, no vendemos, no comercializamos ni recopilamos tu información personal para ningún fin publicitario o comercial.</p>
    </div>

    <h2>1. Recopilación Mínima de Datos</h2>
    <p>FinTrack únicamente solicita y almacena los datos estrictamente necesarios para habilitar tu cuenta y mantener tu sesión activa de manera segura en tus dispositivos móviles. Estos datos se limitan a:</p>
    <ul>
        <li><strong>Nombre o Apodo:</strong> Exclusivamente para identificarte ante los demás miembros de tus grupos financieros creados.</li>
        <li><strong>Dirección de Correo Electrónico:</strong> Como identificador único para iniciar sesión, recuperar tu contraseña y recibir invitaciones a grupos.</li>
        <li><strong>Contraseña Encriptada:</strong> Almacenada mediante algoritmos criptográficos irreversibles (Bcrypt) de un solo sentido. Nadie (ni siquiera los desarrolladores de FinTrack) puede visualizar o descifrar tu contraseña.</li>
    </ul>

    <h2>2. Independencia y Cero Permisos del Teléfono</h2>
    <p>FinTrack opera de forma 100% independiente y autónoma dentro de tu sistema operativo (Android o iOS). Garantizamos las siguientes reglas de confianza:</p>
    <ul>
        <li><strong>Cero Acceso a Sensores o Hardware:</strong> No solicitamos ni requerimos permisos para acceder a tu cámara, micrófono, ubicación por GPS, bluetooth o sensores biométricos.</li>
        <li><strong>Cero Acceso a Datos de Dispositivo:</strong> No leemos tus contactos, galería de fotos, SMS, historial de llamadas, ni archivos de almacenamiento interno del dispositivo.</li>
        <li><strong>Aislamiento de otras Aplicaciones:</strong> Operamos en un sandbox aislado y no interactuamos ni leemos datos de ninguna otra aplicación instalada en tu teléfono.</li>
        <li><strong>Notificaciones Push Opcionales:</strong> El único permiso que solicita la app es el de recibir notificaciones de sistema para alertarte al instante cuando otro usuario de tu grupo de finanzas registre un movimiento de dinero. Este permiso es opcional y puede ser revocado en cualquier momento desde los ajustes del sistema.</li>
    </ul>

    <h2>3. Uso de la Información Financiera</h2>
    <p>Todos los grupos, balances y movimientos de ingresos o egresos que registres dentro de la aplicación son de tu propiedad exclusiva. FinTrack no realiza análisis de comportamiento, minería de datos, ni perfiles financieros sobre tus transacciones.</p>

    <h2>4. Control Total y Derecho a la Eliminación Permanentemente</h2>
    <p>Creemos en el derecho absoluto al olvido. FinTrack te proporciona el control total sobre tus datos en todo momento:</p>
    <ul>
        <li>Si decides salir de un grupo o eliminarlo, los registros asociados se modifican o borran de inmediato de la base de datos central en tiempo real.</li>
        <li>Si decides eliminar tu cuenta de usuario, todos tus datos personales, de dispositivo y registros financieros se purgarán de manera definitiva e irreversible de nuestros servidores, sin conservar copias de seguridad de los mismos.</li>
    </ul>

    <h2>5. Seguridad de las Comunicaciones</h2>
    <p>Todas las transferencias de datos entre la aplicación móvil de FinTrack y nuestros servidores se realizan de manera encriptada utilizando protocolos seguros HTTPS con TLS. Además, implementamos limitadores de tasa de tráfico en nuestros endpoints para evitar ataques de fuerza bruta o abusos.</p>

    <footer>
        <p>&copy; 2026 FinTrack. Todos los derechos reservados.</p>
        <p>Esta política de privacidad cumple rigurosamente con los requisitos de confianza y seguridad exigidos por Google Play Console (Android) y Apple App Store Connect (iOS).</p>
    </footer>
</div>

</body>
</html>
