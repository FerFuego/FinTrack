<?php

namespace App\Services;

use Illuminate\Support\Facades\Http;
use Illuminate\Support\Facades\Log;

class PushNotificationService
{
    /**
     * Send push notifications via FCM HTTP v1.
     * Uses simulation mode if credentials are not configured.
     */
    public function sendNotification(array $tokens, string $title, string $body, array $data = []): void
    {
        if (empty($tokens)) {
            Log::info('[FCM Service] No registered device tokens found for notifications.');
            return;
        }

        $credentialsPath = env('FIREBASE_CREDENTIALS');

        if (!$credentialsPath || !file_exists($credentialsPath)) {
            // Simulation Fallback Mode
            Log::info('[FCM Service - SIMULATION MODE] Push notification triggered.', [
                'recipient_count' => count($tokens),
                'tokens'          => $tokens,
                'title'           => $title,
                'body'            => $body,
                'data'            => $data,
            ]);
            return;
        }

        // Live FCM Dispatch via HTTP v1
        try {
            $accessToken = $this->getGoogleAccessToken($credentialsPath);

            if (!$accessToken) {
                Log::error('[FCM Service] Failed to retrieve Google OAuth2 access token.');
                return;
            }

            $projectId = $this->getProjectIdFromCredentials($credentialsPath);

            foreach ($tokens as $token) {
                $response = Http::withToken($accessToken)
                    ->post("https://fcm.googleapis.com/v1/projects/{$projectId}/messages:send", [
                        'message' => [
                            'token' => $token,
                            'notification' => [
                                'title' => $title,
                                'body'  => $body,
                            ],
                            'data' => array_map('strval', $data),
                            'android' => [
                                'notification' => [
                                    'sound' => 'default',
                                ],
                            ],
                            'apns' => [
                                'payload' => [
                                    'aps' => [
                                        'sound' => 'default',
                                    ],
                                ],
                            ],
                        ],
                    ]);

                if ($response->failed()) {
                    Log::error("[FCM Service] Failed to send push to token: {$token}", [
                        'response' => $response->json(),
                    ]);
                } else {
                    Log::info("[FCM Service] Push sent successfully to token: {$token}");
                }
            }
        } catch (\Exception $e) {
            Log::error('[FCM Service] Exception triggered during live push dispatch: ' . $e->getMessage());
        }
    }

    /**
     * Get OAuth2 access token using Firebase service account JSON.
     */
    private function getGoogleAccessToken(string $credentialsPath): ?string
    {
        try {
            $json = json_decode(file_get_contents($credentialsPath), true);
            $privateKey = $json['private_key'];
            $clientEmail = $json['client_email'];

            $header = json_encode(['alg' => 'RS256', 'typ' => 'JWT']);
            $now = time();
            $payload = json_encode([
                'iss'   => $clientEmail,
                'scope' => 'https://www.googleapis.com/auth/firebase.messaging',
                'aud'   => 'https://oauth2.googleapis.com/token',
                'exp'   => $now + 3600,
                'iat'   => $now,
            ]);

            $base64UrlHeader = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($header));
            $base64UrlPayload = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($payload));

            openssl_sign(
                $base64UrlHeader . "." . $base64UrlPayload,
                $signature,
                $privateKey,
                'SHA256'
            );

            $base64UrlSignature = str_replace(['+', '/', '='], ['-', '_', ''], base64_encode($signature));
            $jwt = $base64UrlHeader . "." . $base64UrlPayload . "." . $base64UrlSignature;

            $response = Http::asForm()->post('https://oauth2.googleapis.com/token', [
                'grant_type'            => 'urn:ietf:params:oauth:grant-type:jwt-bearer',
                'assertion'             => $jwt,
            ]);

            if ($response->failed()) {
                return null;
            }

            return $response->json()['access_token'] ?? null;
        } catch (\Exception $e) {
            Log::error('[FCM Service] OAuth2 signature generation failed: ' . $e->getMessage());
            return null;
        }
    }

    /**
     * Parse project_id from credentials JSON file.
     */
    private function getProjectIdFromCredentials(string $credentialsPath): string
    {
        $json = json_decode(file_get_contents($credentialsPath), true);
        return $json['project_id'] ?? env('FIREBASE_PROJECT_ID', '');
    }
}
