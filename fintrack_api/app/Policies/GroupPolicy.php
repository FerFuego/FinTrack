<?php

namespace App\Policies;

use App\Models\Group;
use App\Models\Transaction;
use App\Models\User;

class GroupPolicy
{
    public function view(User $user, Group $group): bool
    {
        return $group->hasMember($user);
    }

    public function update(User $user, Group $group): bool
    {
        return $group->isOwner($user);
    }

    public function delete(User $user, Group $group): bool
    {
        return $group->isOwner($user);
    }

    public function updateTransaction(User $user, Group $group, Transaction $transaction): bool
    {
        // Owner can edit anyone's. Member can only edit their own.
        return $group->isOwner($user) || $transaction->user_id === $user->id;
    }

    public function deleteTransaction(User $user, Group $group, Transaction $transaction): bool
    {
        return $group->isOwner($user) || $transaction->user_id === $user->id;
    }
}
