<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('notifications', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade'); // Penerima notif
            $table->string('title');
            $table->text('message');
            $table->string('type')->nullable(); // misal: 'payment', 'complaint'
            $table->boolean('is_read')->default(false);
            $table->integer('related_id')->nullable(); // ID transaksi atau komplain terkait
            $table->timestamps();
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('notifications');
    }
};
