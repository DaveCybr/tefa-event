<?php
// app/Models/Order.php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'order_number',
        'user_id',
        'event_id',
        'amount',
        'status',
        'notes',
        'registered_at'
    ];

    protected $casts = [
        'registered_at' => 'datetime',
        'amount' => 'decimal:2'
    ];

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }

    public function event(): BelongsTo
    {
        return $this->belongsTo(Event::class);
    }

    // Generate order number otomatis
    protected static function boot()
    {
        parent::boot();

        static::creating(function ($order) {
            if (empty($order->order_number)) {
                $order->order_number = self::generateOrderNumber();
            }
        });
    }

    /**
     * Generate unique order number
     */
    private static function generateOrderNumber()
    {
        $date = date('Ymd');
        $count = Order::whereDate('created_at', today())->count() + 1;
        $orderNumber = 'ORD-' . $date . '-' . str_pad($count, 4, '0', STR_PAD_LEFT);

        // Check if order number already exists (just in case)
        while (Order::where('order_number', $orderNumber)->exists()) {
            $count++;
            $orderNumber = 'ORD-' . $date . '-' . str_pad($count, 4, '0', STR_PAD_LEFT);
        }

        return $orderNumber;
    }

    // Scope untuk filter berdasarkan status
    public function scopeStatus($query, $status)
    {
        return $query->where('status', $status);
    }

    // Scope untuk order user tertentu
    public function scopeForUser($query, $userId)
    {
        return $query->where('user_id', $userId);
    }

    // Check if order can be cancelled
    public function canBeCancelled()
    {
        return in_array($this->status, ['pending', 'confirmed']) &&
            $this->event->start_date > now();
    }

    // Check if order is confirmed
    public function isConfirmed()
    {
        return $this->status === 'confirmed';
    }

    // Get status badge color for UI
    public function getStatusColorAttribute()
    {
        return match ($this->status) {
            'pending' => 'warning',
            'confirmed' => 'success',
            'cancelled' => 'danger',
            'completed' => 'info',
            default => 'secondary'
        };
    }
}
