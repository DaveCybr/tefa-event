<?php
// Buat migration baru: php artisan make:migration perbaiki_tabel_fcm_tokens

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        // Pertama, hapus tabel fcm_tokens yang bermasalah
        Schema::dropIfExists('fcm_tokens');

        // Buat ulang dengan struktur yang benar
        Schema::create('fcm_tokens', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained('users')->onDelete('cascade');
            $table->string('token', 500); // Gunakan varchar bukan text untuk unique constraint
            $table->string('device_type')->default('android');
            $table->string('device_id')->nullable();
            $table->boolean('is_active')->default(true);
            $table->timestamp('last_used_at')->nullable();
            $table->timestamps();

            // Buat unique constraint setelah struktur tabel selesai
            $table->unique(['user_id', 'token']);
        });
    }

    public function down()
    {
        Schema::dropIfExists('fcm_tokens');
    }
};
