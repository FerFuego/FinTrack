<?php

namespace App\Http\Controllers;

use App\Models\Group;
use App\Models\GroupInvitation;
use Illuminate\Http\Request;
use Illuminate\Http\JsonResponse;

class GroupController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $groups = $request->user()
            ->groups()
            ->with(['owner:id,name,email', 'members:id,name,email'])
            ->withCount('transactions')
            ->get();

        return response()->json($groups);
    }

    public function store(Request $request): JsonResponse
    {
        $validated = $request->validate([
            'name'        => 'required|string|max:100',
            'description' => 'nullable|string|max:255',
            'emoji'       => 'nullable|string|max:10',
            'color'       => 'nullable|string|max:7',
        ]);

        $group = Group::create([
            ...$validated,
            'owner_id' => $request->user()->id,
        ]);

        // Add creator as owner member
        $group->members()->attach($request->user()->id, ['role' => 'owner']);

        // Automatically create a default invitation code on group creation
        $invitation = \App\Models\GroupInvitation::create([
            'group_id'   => $group->id,
            'invited_by' => $request->user()->id,
        ]);

        $group->load(['owner:id,name,email', 'members:id,name,email']);

        $group->invite_code = $invitation->code;

        return response()->json($group, 201);
    }

    public function show(Request $request, Group $group): JsonResponse
    {
        $this->authorize('view', $group);

        $group->load(['owner:id,name,email', 'members:id,name,email']);
        $group->loadCount('transactions');

        $summary = $group->getSummary();

        return response()->json([
            'group'   => $group,
            'summary' => $summary,
        ]);
    }

    public function update(Request $request, Group $group): JsonResponse
    {
        $this->authorize('update', $group);

        $validated = $request->validate([
            'name'        => 'sometimes|string|max:100',
            'description' => 'nullable|string|max:255',
            'emoji'       => 'nullable|string|max:10',
            'color'       => 'nullable|string|max:7',
        ]);

        $group->update($validated);

        return response()->json($group);
    }

    public function destroy(Request $request, Group $group): JsonResponse
    {
        $this->authorize('delete', $group);

        $group->delete();

        return response()->json(['message' => 'Grupo eliminado correctamente.']);
    }

    public function summary(Request $request, Group $group): JsonResponse
    {
        $this->authorize('view', $group);

        $currency = $request->query('currency');
        $summary  = $group->getSummary($currency);

        $recentTransactions = $group->transactions()
            ->with('user:id,name,email')
            ->orderByDesc('date')
            ->orderByDesc('created_at')
            ->limit(10)
            ->get();

        return response()->json([
            'summary'             => $summary,
            'recent_transactions' => $recentTransactions,
        ]);
    }

    // Generate invitation code
    public function createInvitation(Request $request, Group $group): JsonResponse
    {
        $this->authorize('update', $group);

        $request->validate([
            'email' => 'nullable|email',
        ]);

        // Expire old pending invitations
        $group->invitations()->where('status', 'pending')->update(['status' => 'expired']);

        $invitation = GroupInvitation::create([
            'group_id'   => $group->id,
            'invited_by' => $request->user()->id,
            'email'      => $request->email,
        ]);

        return response()->json([
            'invitation' => $invitation,
            'code'       => $invitation->code,
            'expires_at' => $invitation->expires_at,
        ], 201);
    }

    // Join group via code
    public function joinByCode(Request $request): JsonResponse
    {
        $request->validate([
            'code' => 'required|string|size:8',
        ]);

        $invitation = GroupInvitation::where('code', strtoupper($request->code))
            ->where('status', 'pending')
            ->first();

        if (!$invitation || $invitation->isExpired()) {
            return response()->json(['message' => 'Código inválido o expirado.'], 404);
        }

        $group = $invitation->group;
        $user  = $request->user();

        if ($group->hasMember($user)) {
            return response()->json(['message' => 'Ya sos miembro de este grupo.'], 409);
        }

        $group->members()->attach($user->id, ['role' => 'member']);
        $invitation->update(['status' => 'accepted']);

        $group->load(['owner:id,name,email', 'members:id,name,email']);

        return response()->json([
            'message' => '¡Unido al grupo exitosamente!',
            'group'   => $group,
        ]);
    }

    public function removeMember(Request $request, Group $group, int $userId): JsonResponse
    {
        $this->authorize('update', $group);

        if ($group->owner_id === $userId) {
            return response()->json(['message' => 'No se puede eliminar al owner del grupo.'], 403);
        }

        $group->members()->detach($userId);

        return response()->json(['message' => 'Miembro eliminado correctamente.']);
    }

    public function leave(Request $request, Group $group): JsonResponse
    {
        $user = $request->user();

        if ($group->owner_id === $user->id) {
            return response()->json(['message' => 'El owner no puede abandonar el grupo. Eliminalo o transferí la propiedad.'], 403);
        }

        if (!$group->hasMember($user)) {
            return response()->json(['message' => 'No sos miembro de este grupo.'], 404);
        }

        $group->members()->detach($user->id);

        return response()->json(['message' => 'Abandonaste el grupo correctamente.']);
    }
}
