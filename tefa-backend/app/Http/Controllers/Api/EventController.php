<?php
// app/Http/Controllers/Api/EventController.php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Event;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;
use Illuminate\Support\Facades\Auth;

class EventController extends Controller
{
    public function index(Request $request)
    {
        $perPage = $request->get('per_page', 20);
        $search = $request->get('search');
        $page = $request->get('page', 1);

        $query = Event::with(['creator:id,name,email,role'])
            ->orderBy('created_at', 'desc');

        // Apply search filter
        if ($search) {
            $query->search($search);
        }

        $events = $query->paginate($perPage, ['*'], 'page', $page);

        return response()->json([
            'success' => true,
            'message' => 'Events retrieved successfully',
            'data' => [
                'events' => $events->items(),
                'pagination' => [
                    'current_page' => $events->currentPage(),
                    'per_page' => $events->perPage(),
                    'total' => $events->total(),
                    'last_page' => $events->lastPage(),
                    'from' => $events->firstItem(),
                    'to' => $events->lastItem(),
                ]
            ]
        ]);
    }

    public function show($id)
    {
        $event = Event::with(['creator:id,name,email,role'])->find($id);

        if (!$event) {
            return response()->json([
                'success' => false,
                'message' => 'Event not found',
                'data' => null
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Event retrieved successfully',
            'data' => $event
        ]);
    }

    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'title' => 'required|string|max:255',
            'description' => 'required|string',
            'location' => 'required|string|max:255',
            'price' => 'required|numeric|min:0',
            'max_participants' => 'required|integer|min:1',
            'image_url' => 'nullable|url',
            'category' => 'required|string|max:100',
            'start_date' => 'required|date|after:now',
            'end_date' => 'required|date|after:start_date',
            'registration_deadline' => 'required|date|before:start_date',
            'status' => 'in:draft,published,cancelled,completed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data' => $validator->errors()
            ], 422);
        }

        $event = Event::create([
            'title' => $request->title,
            'description' => $request->description,
            'location' => $request->location,
            'price' => $request->price,
            'max_participants' => $request->max_participants,
            'registered_participants' => 0,
            'image_url' => $request->image_url,
            'category' => $request->category,
            'start_date' => $request->start_date,
            'end_date' => $request->end_date,
            'registration_deadline' => $request->registration_deadline,
            'status' => $request->status ?? 'published',
            'created_by' => Auth::id(),
        ]);

        $event->load('creator:id,name,email,role');

        return response()->json([
            'success' => true,
            'message' => 'Event created successfully',
            'data' => $event
        ], 201);
    }

    public function update(Request $request, $id)
    {
        $event = Event::find($id);

        if (!$event) {
            return response()->json([
                'success' => false,
                'message' => 'Event not found',
                'data' => null
            ], 404);
        }

        // Check if user is the creator or has permission
        if (Auth::id() !== $event->created_by && !Auth::user()->isOrganizer()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized to update this event',
                'data' => null
            ], 403);
        }

        $validator = Validator::make($request->all(), [
            'title' => 'sometimes|required|string|max:255',
            'description' => 'sometimes|required|string',
            'location' => 'sometimes|required|string|max:255',
            'price' => 'sometimes|required|numeric|min:0',
            'max_participants' => 'sometimes|required|integer|min:1',
            'image_url' => 'nullable|url',
            'category' => 'sometimes|required|string|max:100',
            'start_date' => 'sometimes|required|date',
            'end_date' => 'sometimes|required|date|after:start_date',
            'registration_deadline' => 'sometimes|required|date|before:start_date',
            'status' => 'in:draft,published,cancelled,completed',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation error',
                'data' => $validator->errors()
            ], 422);
        }

        $event->update($request->all());
        $event->load('creator:id,name,email,role');

        return response()->json([
            'success' => true,
            'message' => 'Event updated successfully',
            'data' => $event
        ]);
    }

    public function destroy($id)
    {
        $event = Event::find($id);

        if (!$event) {
            return response()->json([
                'success' => false,
                'message' => 'Event not found',
                'data' => null
            ], 404);
        }

        // Check if user is the creator or has permission
        if (Auth::id() !== $event->created_by && !Auth::user()->isOrganizer()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized to delete this event',
                'data' => null
            ], 403);
        }

        // Check if event has orders
        if ($event->orders()->count() > 0) {
            return response()->json([
                'success' => false,
                'message' => 'Cannot delete event with existing orders',
                'data' => null
            ], 422);
        }

        $event->delete();

        return response()->json([
            'success' => true,
            'message' => 'Event deleted successfully',
            'data' => null
        ]);
    }
}
