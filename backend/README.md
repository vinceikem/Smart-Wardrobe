# Smart Wardrobe — Backend

This project powers the backend for the Smart Wardrobe application, providing clothing recommendations using the Gemini (GenAI) API.

Note: This project does NOT include a shared API key or demo mode. Production access requires your own Gemini / Google GenAI API key.

---

## Getting Started

### Prerequisites

You will need the following installed to run the server:

- Node.js (version 16+)
- npm or yarn
- A Gemini / Google GenAI API key

### Installation

Navigate to the backend directory and install the necessary dependencies:

```bash
cd "path\Smart Wardrobe\backend"
npm install
```

### Configuration (Environment Variables)

Create a file named `.env` in the root of the backend folder. Do NOT commit this file to version control.

The minimum required variables are:

| Variable         | Description                      | Example Value           |
|------------------|----------------------------------|------------------------|
| GEMINI_API_KEY   | Your personal Gemini API Key.    | your_gemini_api_key_here |
| PORT             | The port the server will run on. | 3000                   |

Example `.env` file:
```bash
GEMINI_API_KEY=your_gemini_api_key_here
PORT=3000
```

### Running the Server

Start the server using one of the following commands:

```bash
# For development (includes auto-restart on file changes)
npm run dev

# For production
npm start
```

## API Endpoint

The primary endpoint handles the wardrobe analysis and outfit prompt. The base path depends on your server configuration (e.g., http://localhost:3000).

### POST /v1/api/prompt

- Content-Type: multipart/form-data
- Form fields:
  - wardrobe — one or more image files (field name: `wardrobe`)
  - event — optional string
  - weather — optional string
  - style — optional string

#### File Naming Convention (Required)

Each uploaded file must follow a specific pattern for the backend to correctly process and identify the item:

- Format: `{prefix}_{tag}.{extension}`
- Exactly one underscore (`_`) must separate the prefix and tag.
- `tag`: This is the unique ID for the garment (e.g., topA, bottom-2). This ID is returned in the API response.
- Allowed Extensions: .png, .jpg, .jpeg (MIME type must be an image).

Example filename: `abc_topA.png`

#### Example Request (cURL)

```bash
curl -X POST "http://localhost:3000/v1/api/prompt" \
  -F "wardrobe=@C:/path/abc_topA.png" \
  -F "wardrobe=@C:/path/xyz_bottomB.jpg" \
  -F "event=casual" \
  -F "weather=rainy" \
  -F "style=minimal"
```

#### Example Response

A successful request returns a JSON object with the recommended outfit items and a brief explanation:

```json
{
  "success": true,
  "message": "Analyzed Image",
  "data": {
    "top": "top-2",
    "bottom": "bottom-2",
    "response": "This combination of the comfortable tiered maxi skirt and the casual v-neck t-shirt is perfect for a class event. The colors complement each other well, offering a relaxed yet appropriate look. Confidence level: High."
  }
}
```

## Security & Observability

- All routes should be protected by rate limiting to prevent abuse and ensure fair usage.
- The API returns structured JSON error responses.
- Ensure all uploaded files adhere to the specified naming convention and format requirements to avoid 400 Bad Request errors.
- Basic logs are printed to the console. For production-grade logging, consider integrating libraries like winston or morgan.

## Folder Structure

```
backend/
├── controllers/    # Request handling logic
├── routes/         # API route definitions
├── services/       # Core business logic (Gemini calls)
├── middleware/       # Necessary middleware
├── uploads/        # Temporary storage for file uploads
├── utils/        # Utility Funtions (Multer Config)
├── .env    # Template for environment variables
├── server.js        # Main server entry point
```

## Deployment

Recommended platforms for deployment include Render, Railway, or any other Node.js-compatible host. Ensure your .env variables (especially GEMINI_API_KEY) are correctly configured in your deployment environment's settings.

## License

MIT