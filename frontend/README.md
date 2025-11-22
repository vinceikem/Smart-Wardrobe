#  Smart Wardrobe Assistant (Flutter)

A modern mobile application designed to simplify wardrobe management and
generate intelligent, personalized outfits using AI. The app blends
local data persistence, smooth UI/UX, and external AI integration to
deliver accurate styling recommendations based on user input.

## ✨ Features

###  Intelligent Outfit Generation

Generate a complete outfit consisting of: - **Top** - **Bottom** -
**Shoes** - **Accessory**

Outfits are generated based on: - Selected **Style** - **Event** type -
Real-time **Weather** conditions

Images of wardrobe items are also sent to the AI to improve accuracy.

###  AI Style Analysis

Each generated outfit includes: - A detailed explanation of why the
outfit works
- A breakdown of color pairing, event suitability, and style
consistency
- A natural-language description users can save or reference later

###  Wardrobe Management

Organize all wardrobe items with: - Category-based grouping
- Item image preview
- Local storage using **Hive**
- Ability to add, view, and manage items anytime --- works offline

###  Saved Outfits

Save any generated outfit to view later.
Saved data includes: - All selected **WardrobeItem IDs** - The AI's
descriptive analysis
- Date generated
- Category/style metadata

###  Clean UI/UX

-   Smooth screen transitions
-   Floating action button (FAB) interactions
-   Minimalist wardrobe grid layout
-   Consistent spacing and design system

## ⚙️ Architecture & Tech Stack

###  State Management --- Provider

Manages: - Wardrobe state
- Current filters
- Generated outfit data
- Saving and retrieving outfits

###  Local Persistence --- Hive

Lightweight NoSQL local database storing: - `WardrobeItem` -
`SavedOutfit`

###  AI Integration --- PromptService

Handles communication with the external AI.
Expected response:

``` json
{
  "top": "string",
  "bottom": "string",
  "shoe": "string",
  "accessory": "string",
  "response": "AI explanation text here"
}
```

## 🚀 Installation & Setup

### 1. Clone the Repository

    git clone repo
    cd smart-wardrobe-assistant

### 2. Install Dependencies

    flutter pub get

### 3. Generate Hive Adapters

    flutter packages pub run build_runner build --delete-conflicting-outputs

### 4. Configure AI Service

Replace `_callOutfitService()` logic with real API integration.

### 5. Run the App

    flutter run

## 📸 Screenshots

![wardrobe_grid](https://github.com/user-attachments/assets/db6d2ee4-6834-4034-a7cc-c6953b61a215)
![generated_outfit](https://github.com/user-attachments/assets/9eae798d-a308-41bd-9aff-ae03dacd6427)
![outfit_generation](https://github.com/user-attachments/assets/d91dc614-7690-4ae2-a36b-d500b7148fd6)

## 🧪 Folder Structure

    lib/
     ├── models/
     ├── providers/
     ├── services/
     ├── screens/
     ├── widgets/
     └── main.dart

## 📄 License

MIT License

## 🤝 Contributing

Fork → Branch → Commit → PR

## 📬 Contact

Email: vince.ikem@gmail.com\
GitHub: https://github.com/vinceikem
