<?php
// database/migrations/2024_01_01_000001_create_events_table.php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up()
    {
        Schema::create('events', function (Blueprint $table) {
            $table->id();
            $table->string('title');
            $table->text('description');
            $table->string('location');
            $table->decimal('price', 10, 2)->default(0);
            $table->integer('max_participants')->default(0);
            $table->integer('registered_participants')->default(0);
            $table->string('image_url')->nullable();
            $table->string('category')->default('general');
            $table->dateTime('start_date');
            $table->dateTime('end_date');
            $table->dateTime('registration_deadline');
            $table->enum('status', ['draft', 'published', 'cancelled', 'completed'])->default('published');
            $table->foreignId('created_by')->constrained('users')->onDelete('cascade');
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('events');
    }
};
