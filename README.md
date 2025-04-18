# 🌐 Liquid Galaxy AI Assistant

**An intelligent, interactive AI interface that lets you explore the world with natural language through Liquid Galaxy visualization.**

---

## 📌 Introduction

Liquid Galaxy AI Assistant is an AI-powered Flutter application that brings together the power of conversational AI and immersive geographic visualization. Users can ask natural language questions such as:

> "Where is Mount Everest?"  
> "Tell me interesting facts about Paris."  
> "Show me the Amazon rainforest."

The assistant responds with detailed, AI-generated answers while simultaneously visualizing the relevant place using the Liquid Galaxy system. The result is a seamless, informative, and visually immersive user experience.

---

## 🧰 Tech Stack

| Component           | Technology        | Role                                                                 |
|---------------------|------------------|----------------------------------------------------------------------|
| **Frontend UI**     | Flutter           | Cross-platform mobile interface (Android/iOS/Desktop).               |
| **AI Engine**       | Gemini Pro        | Natural language understanding and intelligent responses.            |
| **Backend Logic**   | Dart (SSH)        | Remote communication with LG servers using SSH.                      |
| **Visualization**   | Liquid Galaxy     | Multi-display Earth rendering environment.                           |
| **Map Interaction** | KML (Google Earth)| Visual overlays, camera controls, and descriptive labels.            |

---

## 🧠 How the AI Works

The Gemini Pro LLM interprets and processes user queries to understand the meaning and extract any geographical references. Here's how it works step by step:

1. **User Input Parsing**  
   The model reads and comprehends the input sentence. It understands user intent—whether it's a request for information, navigation, or a fun fact.

2. **Geographic Entity Recognition**  
   Gemini identifies place names (e.g., countries, landmarks, natural features). These are tagged and marked for visual interaction.

3. **Response Generation**  
   It crafts a detailed, coherent, and well-structured response based on the query. This text is shown on-screen and added as a visual overlay.

4. **Map Command Triggering**  
   If a location is detected, a visual fly-to command is triggered, and a KML file is generated containing the AI's response.

5. **Fallback Handling**  
   If no specific location is found, only the AI response is shown without triggering Liquid Galaxy visuals.

---

## 🌍 KML Interaction Explained

KML (Keyhole Markup Language) is used to render the visual elements on the Liquid Galaxy. Here's what we control using KML:

### ✈️ Fly-To Animations
```bash
echo "search=Eiffel Tower" > /tmp/query.txt
```

## 🖼️ ScreenOverlay Elements

These allow displaying Gemini’s response in the corner of the Liquid Galaxy screen using KML.

```xml
<ScreenOverlay>
  <name>AI Response</name>
  <Icon>
    <href>http://lg1:81/kmls/ai_text.png</href>
  </Icon>
  <overlayXY x="0" y="1" xunits="fraction" yunits="fraction"/>
  <screenXY x="0.05" y="0.95" xunits="fraction" yunits="fraction"/>
</ScreenOverlay>
```

![_- visual selection (27)](https://github.com/user-attachments/assets/aa30391c-f751-4ead-ae10-5a6fcb57e25d)

![Screenshot 2025-04-18 182843](https://github.com/user-attachments/assets/ec859286-edf3-4523-8d14-f6dea90b9afd)



## Installation Setup
**Clone the Repository**
```bash
git clone https://github.com/your-username/lg-ai-assistant.git
cd lg-ai-assistant
```

**Install Flutter**
```bash
git clone https://github.com/flutter/flutter.git -b stable
export PATH="$PATH:`pwd`/flutter/bin"
flutter doctor
```
**Install Dependencies**
```bash
flutter pub get
```

**Run the App on Device**
```bash
flutter run
```



