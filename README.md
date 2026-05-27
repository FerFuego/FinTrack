# FinTrack 💰

App mobile multiplataforma de **control de gastos e ingresos compartido**, construida con **Flutter** (Android + iOS) y **Laravel** (API REST).

---

## 📁 Estructura del proyecto

```
fintrack/
├── fintrack_api/          # Backend Laravel 11
├── fintrack_app/          # Frontend Flutter
├── docker-compose.yml     # Docker para desarrollo
└── README.md
```

---

## 🚀 Setup Backend (Laravel)

### Requisitos
- PHP 8.2+
- Composer
- MySQL 8.0

### Pasos

```bash
cd fintrack_api

# 1. Instalar dependencias
composer install

# 2. Copiar y configurar .env
cp .env.example .env
php artisan key:generate

# 3. Configurar la BD en .env
# DB_DATABASE=fintrack_db
# DB_USERNAME=tu_usuario
# DB_PASSWORD=tu_contraseña

# 4. Crear la base de datos
mysql -u root -p -e "CREATE DATABASE fintrack_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"

# 5. Ejecutar migraciones y seeders
php artisan migrate --seed

# 6. Iniciar servidor
php artisan serve
# → http://localhost:8000

# Usuarios de prueba (si corriste el seeder):
# alice@fintrack.test / password
# bob@fintrack.test / password
```

### Con Docker

```bash
# Desde la raíz del proyecto
docker-compose up -d

# Luego dentro del container:
docker exec -it fintrack_api bash
composer install
cp .env.example .env
# Editar .env con: DB_HOST=mysql, DB_PASSWORD=fintrack_pass
php artisan key:generate
php artisan migrate --seed
```

---

## 📱 Setup Flutter App

### Requisitos
- Flutter SDK 3.x ([flutter.dev](https://flutter.dev/docs/get-started/install))
- Android Studio (para Android) + AVD
- Xcode 15+ (para iOS, solo macOS)

### Pasos

```bash
cd fintrack_app

# 1. Instalar dependencias
flutter pub get

# 2. Configurar la URL de la API
# Editar: lib/core/network/api_endpoints.dart
# Android emulator → http://10.0.2.2:8000/api
# iOS simulator   → http://localhost:8000/api
# Dispositivo físico → http://TU_IP_LOCAL:8000/api

# 3. Correr en Android
flutter run -d android

# 4. Correr en iOS (macOS + Xcode required)
cd ios && pod install && cd ..
flutter run -d ios
```

### Cambiar URL de la API

Editar `lib/core/network/api_endpoints.dart`:

```dart
// Android emulator
static const String baseUrl = 'http://10.0.2.2:8000/api';

// iOS simulator
static const String baseUrl = 'http://localhost:8000/api';

// Dispositivo físico (reemplazar con tu IP)
static const String baseUrl = 'http://192.168.1.100:8000/api';

// Producción
static const String baseUrl = 'https://api.midominio.com/api';
```

---

## 🔑 Endpoints de la API

### Auth
| Método | Endpoint | Body |
|--------|----------|------|
| POST | `/api/auth/register` | `name, email, password, password_confirmation` |
| POST | `/api/auth/login` | `email, password` |
| POST | `/api/auth/logout` | — (requiere token) |
| POST | `/api/auth/forgot-password` | `email` |
| GET | `/api/user` | — (requiere token) |

### Grupos (requieren token)
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/groups` | Listar grupos |
| POST | `/api/groups` | Crear grupo |
| GET | `/api/groups/{id}` | Ver grupo |
| PUT | `/api/groups/{id}` | Editar grupo |
| DELETE | `/api/groups/{id}` | Eliminar grupo |
| GET | `/api/groups/{id}/summary` | Resumen financiero |
| POST | `/api/groups/{id}/invite` | Crear código de invitación |
| POST | `/api/groups/join` | Unirse con código |
| DELETE | `/api/groups/{id}/leave` | Abandonar grupo |

### Transacciones (requieren token)
| Método | Endpoint | Descripción |
|--------|----------|-------------|
| GET | `/api/groups/{id}/transactions` | Listar (filtros, paginación) |
| POST | `/api/groups/{id}/transactions` | Crear movimiento |
| GET | `/api/groups/{id}/transactions/{tid}` | Ver movimiento |
| PUT | `/api/groups/{id}/transactions/{tid}` | Editar movimiento |
| DELETE | `/api/groups/{id}/transactions/{tid}` | Eliminar movimiento |

**Filtros de transactions:**
```
?type=income|expense
&currency=ARS|USD|EUR
&user_id=1
&date_from=2026-01-01
&date_to=2026-12-31
&search=supermercado
&page=1
&per_page=20
```

---

## 📊 Esquema de Base de Datos

```sql
users (id, name, email, password, ...)
groups (id, name, description, emoji, color, owner_id, ...)
group_user (id, group_id, user_id, role[owner|member], joined_at)
group_invitations (id, group_id, invited_by, email?, code, status, expires_at, ...)
transactions (id, group_id, user_id, amount, currency, description, type, date, category?, notes?, ...)
personal_access_tokens (Sanctum)
```

---

## 🎨 Stack & Dependencias Flutter

```yaml
# Estado
flutter_riverpod: ^2.5.1

# Navegación  
go_router: ^13.2.0

# HTTP
dio: ^5.4.3+1

# Almacenamiento seguro
flutter_secure_storage: ^9.0.0

# Gráficos
fl_chart: ^0.68.0

# Animaciones
flutter_animate: ^4.5.0
shimmer: ^3.0.0

# UI
google_fonts: ^6.2.1
```

---

## 🛡️ Autenticación

- Se usa **Laravel Sanctum** con tokens de API (Bearer Token)
- El token se guarda en **FlutterSecureStorage** (Keychain en iOS, EncryptedSharedPreferences en Android)
- Al iniciar la app, se verifica el token y se refresca el usuario del servidor
- Los endpoints protegidos rechazan requests sin token válido con HTTP 401

---

## 🔄 Sincronización

Los datos se actualizan mediante **pull-to-refresh** en todas las pantallas. Para sincronización automática, se puede agregar polling con `Timer.periodic`:

```dart
// Agregar en DashboardScreen:
Timer.periodic(Duration(seconds: 30), (_) => _load());
```

Para WebSockets reales, se puede integrar **Laravel Echo** + **Pusher**.

---

## 📂 Arquitectura Flutter

```
lib/
├── main.dart              # Entry point
├── app.dart               # Router + MaterialApp
├── core/
│   ├── constants/         # Colores, tema
│   ├── network/           # Dio client, endpoints
│   └── storage/           # SecureStorage
├── features/
│   ├── auth/              # Login, Register, ForgotPassword
│   ├── groups/            # Grupos, crear, invitar
│   ├── transactions/      # Dashboard, Historial, Agregar
│   └── profile/           # Perfil, logout
└── shared/
    ├── models/            # UserModel, GroupModel, TransactionModel
    └── widgets/           # MainShell (tab bar), componentes reutilizables
```

Patrón: **Feature-first + Repository pattern + Riverpod**

---

## 🧪 Probar la API con curl

```bash
# 1. Login
curl -X POST http://localhost:8000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"alice@fintrack.test","password":"password"}'

# 2. Listar grupos (usar el token del paso anterior)
curl http://localhost:8000/api/groups \
  -H "Authorization: Bearer TU_TOKEN"

# 3. Agregar transacción
curl -X POST http://localhost:8000/api/groups/1/transactions \
  -H "Authorization: Bearer TU_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"amount":5000,"currency":"ARS","description":"Supermercado","type":"expense","date":"2026-05-26"}'
```

---

## 🚢 Deploy en producción

### Backend
1. Subir a un VPS (DigitalOcean, Fly.io, Railway)
2. Configurar MySQL en producción
3. Cambiar `APP_ENV=production`, `APP_DEBUG=false`
4. Configurar Nginx + PHP-FPM
5. `php artisan config:cache && php artisan route:cache`

### Flutter
1. Cambiar la URL base en `api_endpoints.dart`
2. **Android:** `flutter build apk --release` o `flutter build appbundle`
3. **iOS:** `flutter build ios --release` → Archivar desde Xcode → App Store Connect

---

## 📄 Licencia

MIT
