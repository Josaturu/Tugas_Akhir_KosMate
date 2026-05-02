<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('complaints', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // Siapa yang lapor
            $table->foreignId('kamar_id')->constrained()->onDelete('cascade'); // Kamar mana
            $table->string('category'); // Listrik, Air, Wifi, dll
            $table->text('description');
            $table->string('image')->nullable();
            $table->enum('status', ['pending', 'processing', 'resolved'])->default('pending');
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('complaints');
    }
};
