<?php
// database/seeders/UserSeeder.php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class UserSeeder extends Seeder
{
    public function run(): void
    {
        // Buat user organizer
        User::create([
            'name' => 'Event Organizer',
            'email' => 'organizer@tefa.com',
            'password' => Hash::make('password123'),
            'role' => 'organizer',
            'phone' => '081234567890',
            'address' => 'Jl. Organizer Street No. 1, Jakarta'
        ]);

        // Buat user participant
        User::create([
            'name' => 'John Participant',
            'email' => 'participant@tefa.com',
            'password' => Hash::make('password123'),
            'role' => 'participant',
            'phone' => '081234567891',
            'address' => 'Jl. Participant Street No. 2, Jakarta'
        ]);

        User::create([
            'name' => 'Jane Doe',
            'email' => 'jane@tefa.com',
            'password' => Hash::make('password123'),
            'role' => 'participant',
            'phone' => '081234567892',
            'address' => 'Jl. Participant Street No. 3, Jakarta'
        ]);

        // Buat user dummy tambahan
        for ($i = 4; $i <= 10; $i++) {
            User::create([
                'name' => "User $i",
                'email' => "user$i@tefa.com",
                'password' => Hash::make('password123'),
                'role' => $i % 3 === 0 ? 'organizer' : 'participant',
                'phone' => "08123456789$i",
                'address' => "Jl. User Street No. $i, Jakarta"
            ]);
        }

        // Tambahan: Buat admin user
        User::create([
            'name' => 'Administrator',
            'email' => 'admin@tefa.com',
            'password' => Hash::make('password123'),
            'role' => 'admin',
            'phone' => '081234567899',
            'address' => 'Jl. Admin Street No. 999, Jakarta'
        ]);
    }
}
