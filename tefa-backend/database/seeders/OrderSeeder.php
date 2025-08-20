<?php
// database/seeders/OrderSeeder.php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Order;
use App\Models\User;
use App\Models\Event;

class OrderSeeder extends Seeder
{
    public function run(): void
    {
        $participants = User::where('role', 'participant')->get();
        $events = Event::all();

        // Create some dummy orders
        $orders = [
            [
                'user_id' => $participants->first()->id,
                'event_id' => $events->first()->id,
                'amount' => $events->first()->price,
                'status' => 'confirmed',
                'notes' => 'Pembayaran via transfer bank'
            ],
            [
                'user_id' => $participants->skip(1)->first()->id,
                'event_id' => $events->first()->id,
                'amount' => $events->first()->price,
                'status' => 'pending',
                'notes' => 'Menunggu konfirmasi pembayaran'
            ],
            [
                'user_id' => $participants->first()->id,
                'event_id' => $events->skip(1)->first()->id,
                'amount' => $events->skip(1)->first()->price,
                'status' => 'confirmed',
                'notes' => 'Pembayaran via e-wallet'
            ],
            [
                'user_id' => $participants->skip(2)->first()->id,
                'event_id' => $events->skip(5)->first()->id, // FREE event
                'amount' => 0,
                'status' => 'confirmed',
                'notes' => 'Event gratis'
            ]
        ];

        foreach ($orders as $orderData) {
            Order::create($orderData);
        }

        // Create more random orders
        for ($i = 0; $i < 10; $i++) {
            $event = $events->random();
            $participant = $participants->random();

            Order::create([
                'user_id' => $participant->id,
                'event_id' => $event->id,
                'amount' => $event->price,
                'status' => collect(['pending', 'confirmed', 'completed'])->random(),
                'notes' => 'Auto generated order for testing'
            ]);
        }
    }
}
