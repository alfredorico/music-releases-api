# Programming Assessment

Complete the following steps to implement a releases API endpoint:

## Step 1: Create a GET endpoint for releases

Create a new GET endpoint at `/api/releases` that returns all releases.

## Step 2: Return the correct JSON format

The endpoint should return an array of releases with the following structure:

```json
[
  {
    "id": 1,
    "name": "Sound Music",
    "album": {
      "name": "Sound Music - Single"
    },
    "artists": [
      {
        "id": 1,
        "name": "Jane D"
      }
    ],
    "created_at": "2021-01-22T12:34:56-06:00",
    "released_at": "2021-01-24T04:00:00-06:00",
    "duration_in_minutes": 55
  }
]
```

## Step 3: Add filtering by release date

Implement a `past` parameter to filter releases by their release date:

- `GET /api/releases?past=1` - Returns only releases that have already been released (past releases)
- `GET /api/releases?past=0` - Returns only releases that will be released in the future (upcoming releases)
- `GET /api/releases` (no param) - Returns all releases

## Step 4: Add pagination

Implement pagination for the endpoint:

- Default: Return 10 records per page
- Support a `limit` parameter to customize the number of records returned
- Example: `GET /api/releases?limit=20` should return 20 records
- Include appropriate metadata in the response (e.g., total count)