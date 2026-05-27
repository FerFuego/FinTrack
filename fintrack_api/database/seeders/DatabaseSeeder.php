<?php

namespace Database\Seeders;

use App\Models\Group;
use App\Models\Transaction;
use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run(): void
    {
        // Create two test users
        $alice = User::create([
            'name'     => 'Alice García',
            'email'    => 'alice@fintrack.test',
            'password' => Hash::make('password'),
        ]);

        $bob = User::create([
            'name'     => 'Bob Martínez',
            'email'    => 'bob@fintrack.test',
            'password' => Hash::make('password'),
        ]);

        // Create a shared group
        $group = Group::create([
            'name'        => 'Familia García',
            'description' => 'Gastos del hogar',
            'emoji'       => '🏠',
            'color'       => '#6C63FF',
            'owner_id'    => $alice->id,
        ]);

        // Attach both users
        $group->members()->attach($alice->id, ['role' => 'owner']);
        $group->members()->attach($bob->id,   ['role' => 'member']);

        // Sample transactions
        $transactions = [
            ['amount' => 150000, 'currency' => 'ARS', 'description' => 'Sueldo Febrero', 'type' => 'income',  'date' => '2026-02-01', 'user_id' => $alice->id],
            ['amount' => 45000,  'currency' => 'ARS', 'description' => 'Supermercado',   'type' => 'expense', 'date' => '2026-02-05', 'user_id' => $alice->id],
            ['amount' => 12000,  'currency' => 'ARS', 'description' => 'Luz y gas',       'type' => 'expense', 'date' => '2026-02-10', 'user_id' => $bob->id],
            ['amount' => 500,    'currency' => 'USD', 'description' => 'Freelance USD',   'type' => 'income',  'date' => '2026-02-15', 'user_id' => $bob->id],
            ['amount' => 8500,   'currency' => 'ARS', 'description' => 'Nafta',            'type' => 'expense', 'date' => '2026-02-20', 'user_id' => $alice->id],
            ['amount' => 200000, 'currency' => 'ARS', 'description' => 'Sueldo Marzo',    'type' => 'income',  'date' => '2026-03-01', 'user_id' => $alice->id],
            ['amount' => 30000,  'currency' => 'ARS', 'description' => 'Internet',         'type' => 'expense', 'date' => '2026-03-03', 'user_id' => $bob->id],
            ['amount' => 250,    'currency' => 'USD', 'description' => 'Suscripciones',   'type' => 'expense', 'date' => '2026-03-10', 'user_id' => $alice->id],
        ];

        foreach ($transactions as $data) {
            Transaction::create([
                ...$data,
                'group_id' => $group->id,
            ]);
        }

        $this->command->info('✅ Seeder ejecutado: alice@fintrack.test / bob@fintrack.test (password: password)');
    }
}
