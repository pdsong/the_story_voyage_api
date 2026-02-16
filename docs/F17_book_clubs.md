# F17: Book Clubs

## Overview
The Book Clubs feature allows users to create and join communities, participate in discussions, and vote on topics.

## Features
- **Create Club**: Users can create public or private clubs. Becomes "admin" automatically.
- **Join Club**:
    - **Public**: Immediate membership.
    - **Private**: Membership request (status "pending"). (Note: Approval logic is future work, currently just sets status).
- **Discussions (Threads)**: Members can post threads.
- **Voting**: Members can vote on threads (e.g., polls). Duplicate voting is prevented.

## API Endpoints

### Clubs

- `GET /api/v1/clubs`
    - List all public clubs.
    - Response: `200 OK`, `[{id, name, description, is_private, owner_id}]`

- `POST /api/v1/clubs`
    - Create a new club.
    - Body: `{"club": {"name": "...", "description": "...", "is_private": boolean}}`
    - Response: `201 Created`, Club details.

- `GET /api/v1/clubs/:id`
    - Get club details.
    - Response: `200 OK`, Club details.

- `POST /api/v1/clubs/:id/join`
    - Join a club.
    - Response: `201 Created`, `{"message": "Joined successfully request sent"}`

### Threads

- `GET /api/v1/clubs/:id/threads`
    - List threads in a club.
    - Response: `200 OK`, `[{id, title, content, vote_count, creator_id, inserted_at}]`

- `POST /api/v1/clubs/:id/threads`
    - Create a thread.
    - Body: `{"thread": {"title": "...", "content": "...", "vote_count": 0}}`
    - Response: `201 Created`, Thread details.

- `POST /api/v1/clubs/:id/threads/:thread_id/vote`
    - Vote on a thread.
    - Response: `200 OK`, `{"message": "Voted successfully"}`.
    - Error: `409 Conflict` if already voted (generic changeset error currently returns 422, but constraint logic exists).

## Database Schema

- **clubs**: `name`, `description`, `is_private`, `owner_id`.
- **club_members**: `club_id`, `user_id`, `role`, `status`.
- **club_threads**: `club_id`, `title`, `content`, `vote_count`, `creator_id`.
- **thread_votes**: `thread_id`, `user_id`. (Unique constraint on `[thread_id, user_id]`).
