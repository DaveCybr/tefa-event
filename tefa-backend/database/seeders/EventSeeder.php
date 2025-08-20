<?php
// database/seeders/EventSeeder.php

namespace Database\Seeders;

use Illuminate\Database\Console\Seeds\WithoutModelEvents;
use Illuminate\Database\Seeder;
use App\Models\Event;
use App\Models\User;
use Carbon\Carbon;

class EventSeeder extends Seeder
{
    public function run(): void
    {
        $organizer = User::where('role', 'organizer')->first();

        $events = [
            [
                'title' => 'Workshop Mobile Development dengan Flutter',
                'description' => 'Pelajari cara membuat aplikasi mobile menggunakan Flutter framework. Workshop ini cocok untuk pemula yang ingin memulai karir sebagai mobile developer.',
                'location' => 'Gedung Teknologi, Lantai 3, Ruang 301',
                'price' => 150000,
                'max_participants' => 30,
                'registered_participants' => 15,
                'image_url' => 'https://via.placeholder.com/400x300?text=Flutter+Workshop',
                'category' => 'technology',
                'start_date' => Carbon::now()->addDays(7)->setTime(9, 0),
                'end_date' => Carbon::now()->addDays(7)->setTime(17, 0),
                'registration_deadline' => Carbon::now()->addDays(5),
                'status' => 'published'
            ],
            [
                'title' => 'Seminar Digital Marketing Strategy 2024',
                'description' => 'Strategi pemasaran digital terbaru untuk meningkatkan penjualan bisnis Anda di era digital. Pembicara dari praktisi berpengalaman.',
                'location' => 'Auditorium Utama, Kampus Jakarta',
                'price' => 75000,
                'max_participants' => 100,
                'registered_participants' => 45,
                'image_url' => 'https://via.placeholder.com/400x300?text=Digital+Marketing',
                'category' => 'business',
                'start_date' => Carbon::now()->addDays(10)->setTime(8, 0),
                'end_date' => Carbon::now()->addDays(10)->setTime(16, 0),
                'registration_deadline' => Carbon::now()->addDays(7),
                'status' => 'published'
            ],
            [
                'title' => 'Bootcamp Data Science & AI',
                'description' => 'Intensive 3-day bootcamp covering Python, Machine Learning, dan Artificial Intelligence. Termasuk hands-on project dan sertifikat.',
                'location' => 'Lab Komputer A & B',
                'price' => 500000,
                'max_participants' => 25,
                'registered_participants' => 18,
                'image_url' => 'https://via.placeholder.com/400x300?text=Data+Science+AI',
                'category' => 'technology',
                'start_date' => Carbon::now()->addDays(14)->setTime(9, 0),
                'end_date' => Carbon::now()->addDays(16)->setTime(17, 0),
                'registration_deadline' => Carbon::now()->addDays(10),
                'status' => 'published'
            ],
            [
                'title' => 'Workshop UI/UX Design Fundamentals',
                'description' => 'Belajar dasar-dasar desain UI/UX menggunakan Figma. Dari research, wireframing, prototyping hingga user testing.',
                'location' => 'Design Studio, Gedung Kreatif Lt. 2',
                'price' => 200000,
                'max_participants' => 20,
                'registered_participants' => 8,
                'image_url' => 'https://via.placeholder.com/400x300?text=UI+UX+Design',
                'category' => 'design',
                'start_date' => Carbon::now()->addDays(21)->setTime(10, 0),
                'end_date' => Carbon::now()->addDays(21)->setTime(18, 0),
                'registration_deadline' => Carbon::now()->addDays(18),
                'status' => 'published'
            ],
            [
                'title' => 'Conference: Future of Technology',
                'description' => 'Konferensi teknologi terbesar tahun ini. Menghadirkan pembicara dari Google, Microsoft, dan startup unicorn Indonesia.',
                'location' => 'Jakarta Convention Center',
                'price' => 300000,
                'max_participants' => 500,
                'registered_participants' => 234,
                'image_url' => 'https://via.placeholder.com/400x300?text=Tech+Conference',
                'category' => 'technology',
                'start_date' => Carbon::now()->addDays(30)->setTime(8, 0),
                'end_date' => Carbon::now()->addDays(30)->setTime(18, 0),
                'registration_deadline' => Carbon::now()->addDays(25),
                'status' => 'published'
            ],
            [
                'title' => 'FREE: Career Talk - Tech Industry',
                'description' => 'Gratis! Sharing session tentang karir di industri teknologi. Tips interview, portfolio, dan networking untuk fresh graduate.',
                'location' => 'Aula Kampus, Gedung A',
                'price' => 0,
                'max_participants' => 80,
                'registered_participants' => 52,
                'image_url' => 'https://via.placeholder.com/400x300?text=Career+Talk',
                'category' => 'career',
                'start_date' => Carbon::now()->addDays(5)->setTime(14, 0),
                'end_date' => Carbon::now()->addDays(5)->setTime(17, 0),
                'registration_deadline' => Carbon::now()->addDays(3),
                'status' => 'published'
            ]
        ];

        foreach ($events as $eventData) {
            Event::create(array_merge($eventData, [
                'created_by' => $organizer->id
            ]));
        }
    }
}
