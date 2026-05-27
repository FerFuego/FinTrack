<?php

namespace App\Http\Controllers;

use App\Models\Group;
use App\Models\Transaction;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class TransactionController extends Controller
{
    public function index(Request $request, Group $group): JsonResponse
    {
        $this->authorize('view', $group);

        $query = $group->transactions()->with('user:id,name,email');

        // Filters
        if ($request->filled('type')) {
            $query->where('type', $request->type);
        }

        if ($request->filled('currency')) {
            $query->where('currency', $request->currency);
        }

        if ($request->filled('user_id')) {
            $query->where('user_id', $request->user_id);
        }

        if ($request->filled('date_from')) {
            $query->whereDate('date', '>=', $request->date_from);
        }

        if ($request->filled('date_to')) {
            $query->whereDate('date', '<=', $request->date_to);
        }

        if ($request->filled('search')) {
            $query->where('description', 'LIKE', "%{$request->search}%");
        }

        $perPage       = (int) $request->query('per_page', 20);
        $transactions  = $query->orderByDesc('date')
            ->orderByDesc('created_at')
            ->paginate($perPage);

        return response()->json($transactions);
    }

    public function store(Request $request, Group $group): JsonResponse
    {
        $this->authorize('view', $group);

        $validated = $request->validate([
            'amount'      => 'required|numeric|min:0.01',
            'currency'    => 'required|in:ARS,USD,EUR',
            'description' => 'required|string|max:255',
            'type'        => 'required|in:income,expense',
            'date'        => 'required|date',
            'category'    => 'nullable|string|max:50',
            'notes'       => 'nullable|string|max:500',
        ]);

        $transaction = $group->transactions()->create([
            ...$validated,
            'user_id' => $request->user()->id,
        ]);

        $transaction->load('user:id,name,email');

        // Dispatch push notifications to all other group members in the background
        try {
            $otherMembersTokens = $group->members()
                ->where('users.id', '!=', $request->user()->id)
                ->join('device_tokens', 'users.id', '=', 'device_tokens.user_id')
                ->pluck('device_tokens.token')
                ->toArray();

            if (!empty($otherMembersTokens)) {
                $pushService = app(\App\Services\PushNotificationService::class);
                
                // Format type labels and amount
                $typeLabel = $transaction->type === 'income' ? 'Ingreso' : 'Egreso';
                $symbol = $transaction->currency === 'ARS' ? '$' : $transaction->currency;
                $formattedAmount = "{$symbol} " . number_format($transaction->amount, 2);

                $pushService->sendNotification(
                    $otherMembersTokens,
                    "💰 Nuevo movimiento en {$group->name}!",
                    "{$request->user()->name} registró un {$typeLabel} de {$formattedAmount} (Desc: {$transaction->description}).",
                    [
                        'group_id'       => (string) $group->id,
                        'transaction_id' => (string) $transaction->id,
                    ]
                );
            }
        } catch (\Exception $e) {
            // Silence exceptions so push failure never blocks saving the transaction
            \Illuminate\Support\Facades\Log::warning('[Transaction Push] Failed to dispatch push notification: ' . $e->getMessage());
        }

        return response()->json($transaction, 201);
    }

    public function show(Request $request, Group $group, Transaction $transaction): JsonResponse
    {
        $this->authorize('view', $group);
        $this->ensureBelongsToGroup($group, $transaction);

        $transaction->load('user:id,name,email');

        return response()->json($transaction);
    }

    public function update(Request $request, Group $group, Transaction $transaction): JsonResponse
    {
        $this->authorize('updateTransaction', [$group, $transaction]);
        $this->ensureBelongsToGroup($group, $transaction);

        $validated = $request->validate([
            'amount'      => 'sometimes|numeric|min:0.01',
            'currency'    => 'sometimes|in:ARS,USD,EUR',
            'description' => 'sometimes|string|max:255',
            'type'        => 'sometimes|in:income,expense',
            'date'        => 'sometimes|date',
            'category'    => 'nullable|string|max:50',
            'notes'       => 'nullable|string|max:500',
        ]);

        $transaction->update($validated);
        $transaction->load('user:id,name,email');

        return response()->json($transaction);
    }

    public function destroy(Request $request, Group $group, Transaction $transaction): JsonResponse
    {
        $this->authorize('deleteTransaction', [$group, $transaction]);
        $this->ensureBelongsToGroup($group, $transaction);

        $transaction->delete();

        return response()->json(['message' => 'Movimiento eliminado correctamente.']);
    }

    private function ensureBelongsToGroup(Group $group, Transaction $transaction): void
    {
        if ($transaction->group_id !== $group->id) {
            abort(404, 'El movimiento no pertenece a este grupo.');
        }
    }
}
