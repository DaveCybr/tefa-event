<?php
// app/Http/Controllers/Api/OrderController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\DB;

class OrderController extends Controller
{
    public function index(Request $request)
    {
        $perPage = $request->get('per_page', 20);
        $page = $request->get('page', 1);
        $status = $request->get('status');

        $query = Order::with(['user:id,name,email', 'event:id,title,location,start_date,price'])
            ->orderBy('created_at', 'desc');

        // Filter by authenticated user's orders (unless organizer)
        if (!Auth::user()->isOrganizer()) {
            $query->where('user_id', Auth::id());
        }

        // Filter by status if provided
        if ($status) {
            $query->where('status', $status);
        }

        $orders = $query->paginate($perPage, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'message' => 'Orders retrieved successfully',
            'data' => [
                'orders' => $orders->items(),
                'pagination' => [
                    'current_page' => $orders->currentPage(),
                    'per_page' => $orders->perPage(),
                    'total' => $orders->total(),
                    'last_page' => $orders->lastPage(),
                    'from' => $orders->firstItem(),
                    'to' => $orders->lastItem(),
                ]
            ]
        ]);
    }

    public function show($id)
    {
        $order = Order::with(['user:id,name,email,phone', 'event'])->find($id);

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found',
                'data' => null
            ], 404);
        }

        // Check if user can access this order
        if (!Auth::user()->isOrganizer() && $order->user_id !== Auth::id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized to access this order',
                'data' => null
            ], 403);
        }

        return response()->json([
            'success' => true,
            'message' => 'Order retrieved successfully',
            'data' => $order
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'event_id' => 'required|exists:events,id',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data' => $validator->errors()
            ], 422);
        }

        $event = Event::find($request->event_id);

        // Check if event is still accepting registrations
        if ($event->registration_deadline < now()) {
            return response()->json([
                'success' => false,
                'message' => 'Registration deadline has passed',
                'data' => null
            ], 422);
        }

        // Check if event is not full
        if ($event->registered_participants >= $event->max_participants) {
            return response()->json([
                'success' => false,
                'message' => 'Event is fully booked',
                'data' => null
            ], 422);
        }

        // Check if user already registered for this event
        $existingOrder = Order::where('user_id', Auth::id())
            ->where('event_id', $request->event_id)
            ->whereIn('status', ['pending', 'confirmed'])
            ->first();

        if ($existingOrder) {
            return response()->json([
                'success' => false,
                'message' => 'You have already registered for this event',
                'data' => null
            ], 422);
        }

        DB::transaction(function () use ($request, $event, &$order) {
            // Create order
            $order = Order::create([
                'user_id' => Auth::id(),
                'event_id' => $request->event_id,
                'amount' => $event->price,
                'status' => $event->price > 0 ? 'pending' : 'confirmed',
                'notes' => $request->notes,
                'registered_at' => now(),
            ]);

            // Update event registered participants count
            $event->increment('registered_participants');
        });

        $order->load(['user:id,name,email', 'event:id,title,location,start_date,price']);

        return response()->json([
            'success' => true,
            'message' => 'Order created successfully',
            'data' => $order
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $order = Order::find($id);

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found',
                'data' => null
            ], 404);
        }

        // Only organizers can update order status
        if (!Auth::user()->isOrganizer()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized to update order',
                'data' => null
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'status' => 'required|in:pending,confirmed,cancelled,completed',
            'notes' => 'nullable|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data' => $validator->errors()
            ], 422);
        }

        $oldStatus = $order->status;
        $newStatus = $request->status;

        DB::transaction(function () use ($order, $request, $oldStatus, $newStatus) {
            $order->update($request->only(['status', 'notes']));

            // Update event participants count based on status change
            if ($oldStatus !== $newStatus) {
                $event = $order->event;

                // If cancelling a confirmed order, decrease participants count
                if (in_array($oldStatus, ['confirmed', 'completed']) && $newStatus === 'cancelled') {
                    $event->decrement('registered_participants');
                }

                // If confirming a pending order, keep count (already incremented when created)
                // If changing from cancelled to confirmed, increase count
                if ($oldStatus === 'cancelled' && in_array($newStatus, ['confirmed', 'completed'])) {
                    $event->increment('registered_participants');
                }
            }
        });

        $order->load(['user:id,name,email', 'event:id,title,location,start_date,price']);

        return response()->json([
            'success' => true,
            'message' => 'Order updated successfully',
            'data' => $order
        ]);
    }

    public function destroy($id)
    {
        $order = Order::find($id);

        if (!$order) {
            return response()->json([
                'success' => false,
                'message' => 'Order not found',
                'data' => null
            ], 404);
        }

        // Check authorization
        if (!Auth::user()->isOrganizer() && $order->user_id !== Auth::id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized to delete this order',
                'data' => null
            ], 403);
        }

        DB::transaction(function () use ($order) {
            // Decrease event participants count if order was confirmed
            if (in_array($order->status, ['confirmed', 'completed'])) {
                $order->event->decrement('registered_participants');
            }

            $order->delete();
        });

        return response()->json([
            'success' => true,
            'message' => 'Order deleted successfully',
            'data' => null
        ]);
    }

    // Get user's order history
    public function myOrders(Request $request)
    {
        $perPage = $request->get('per_page', 20);
        $page = $request->get('page', 1);

        $orders = Order::with(['event:id,title,location,start_date,price,image_url'])
            ->where('user_id', Auth::id())
            ->orderBy('created_at', 'desc')
            ->paginate($perPage, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'message' => 'Your orders retrieved successfully',
            'data' => [
                'orders' => $orders->items(),
                'pagination' => [
                    'current_page' => $orders->currentPage(),
                    'per_page' => $orders->perPage(),
                    'total' => $orders->total(),
                    'last_page' => $orders->lastPage(),
                    'from' => $orders->firstItem(),
                    'to' => $orders->lastItem(),
                ]
            ]
        ]);
    }
}
