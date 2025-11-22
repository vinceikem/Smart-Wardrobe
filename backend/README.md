# Smart Wardrobe API

## 💡 AI-Powered Outfit Suggestor

The Smart Wardrobe API utilizes advanced AI to analyze user wardrobe items (via images) and suggest optimal outfit combinations based on specified criteria like event, style, and weather. This is your personal digital stylist, providing intelligent, context-aware fashion advice.

-----

### Base URL

All endpoints are prefixed with the base URL for the API deployment (e.g., `https://api.smartwardrobe.com`).

| Status | Model | Environment |
| :----- | :---- | :---------- |
| **Stable** | `gemini-2.5-flash` | Production |

-----

### 1\. Outfit Suggestion Endpoint

This is the primary endpoint for submitting wardrobe items and context to receive an outfit suggestion.

#### `POST /v1/api/prompt`

**Request Type:** `POST`
**Content Type:** `multipart/form-data`

| Parameter | Required | Type | Description |
| :--- | :---: | :--- | :--- |
| `wardrobe` | **Yes** | File (Image) | A collection of image files representing the clothing items to analyze. **Maximum of 10 files.** |
| `event` | No | String | The occasion for the outfit (e.g., "job interview", "casual dinner", "class event"). |
| `style` | No | String | The desired style (e.g., "minimalist", "bohemian", "professional"). |
| `weather` | No | String | The current weather or climate (e.g., "sunny and 70°F", "rainy", "cold"). |

#### 🖼️ Image Naming Convention (MANDATORY)

For successful analysis, each image file sent under the `wardrobe` key **must** follow the naming convention:

`[category]-[id]`

**Example Image Files:**

  * `top-[id]` (for the first top item)
  * `bottom-[id]` (for the second pair of pants/skirt)
  * `shoes-1`
  * `accessory-3`

-----

### 2\. Sample Response

A successful request returns a suggested outfit combination along with a human-readable explanation and confidence level.

**Status Code:** `200 OK`

```json
{
  "success": true,
  "message": "Analyzed Image",
  "data": {
    "top": "#we2djs2",
    "bottom": "#2werd8sbc",
    "response": "This combination of the comfortable tiered maxi skirt and the casual v-neck t-shirt is perfect for a class event. The colors complement each other well, offering a relaxed yet appropriate look. Confidence level: High."
  }
}
```
| Field | Type | Description |
| :--- | :--- | :--- |
| `success` | Boolean | `true` if the analysis was successful. |
| `message` | String | A brief status message. |
| `data.top` | String | A unique identifier for the suggested top item from the input wardrobe. |
| `data.bottom` | String | A unique identifier for the suggested bottom item from the input wardrobe. |
| `data.response` | String | The AI's detailed explanation, styling notes, and confidence level for the suggested outfit. |


### 3\. API Health Check
Use this endpoint to confirm that the service is running and accessible.

`GET /health`

**Request Type**: `GET` **Response**: Returns a simple JSON object confirming status.

**Status Code**: `200 OK`

```json
{
  "success": true,
  "message": "Server Health Check",
  "data": {
    "status": "OK",
    "uptime": "00:05:43" 
  }
}
```
### 4\. Rate Limiting

The `/v1/api/prompt` route is protected by rate limiting to ensure fair usage and service stability. Please implement proper backoff mechanisms in your client application if you encounter `429 Too Many Requests` errors.