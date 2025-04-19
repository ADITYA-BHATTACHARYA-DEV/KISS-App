



# 🌐 Liquid Galaxy AI Assistant
<div align="center">
  <img src="https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSxD3HaM3uzM9g-cpx5EghQVM6jMp56f59tHg&s" alt="Centered Image" />
</div>

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


<div align="center">
  <img src="https://github.com/user-attachments/assets/e81ac6df-85f3-48da-802e-8756e5a5a2d4" alt="Centered Image"  height=500 width =500 />
</div>






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




<div align="center">
  <img src="https://github.com/user-attachments/assets/ec859286-edf3-4523-8d14-f6dea90b9afd" alt="Centered Image"   height=500 width =800/>
</div>



## 🔐 SSH Integration for Remote Control
The core functionality of this application revolves around its ability to remotely control the Liquid Galaxy (LG) system using Secure Shell (SSH) protocol. By leveraging Dart's built-in Process.run() function and third-party SSH packages, the app communicates directly with the LG master node (lg1) to send commands, upload data, and trigger visual actions.

This allows the system to behave seamlessly and autonomously, transforming AI-generated insights into live visualizations on the Liquid Galaxy cluster without manual intervention.

**🔁 Remote Actions Executed via SSH**
➤ 1. Fly-To Location Command
Command:

```bash
echo "search=Grand Canyon" > /tmp/query.txt
```

**Explanation:**

This command writes a string (e.g., search=Grand Canyon) to the /tmp/query.txt file on the LG master node.

Liquid Galaxy continuously monitors this file and uses its content to zoom into a location.

As a result, once this file is updated, the LG system automatically animates a smooth camera transition to the specified place on Earth.

This approach ensures instant geographical positioning on user request.

➤ 2. Upload Generated KML File
Command:

```bash
scp ai_response.kml lg@lg1:/var/www/html/kmls/
```


**Explanation:**

This uses the Secure Copy Protocol (SCP) to transfer the generated KML (Keyhole Markup Language) file to the LG master node.

The KML file is uploaded to the kmls/ directory inside the LG web server's root (/var/www/html).

These files are then accessible to LG's built-in KML loader via HTTP (e.g., http://lg1:81/kmls/ai_response.kml).

The content of the KML file typically contains AI responses formatted as screen overlays, which are rendered on the globe visualization in LG.

➤ 3. Update KML Reference List
Command:

```bash
echo "http://lg1:81/kmls/ai_response.kml" > /tmp/kmls.txt
```


**Explanation:**

This command tells LG to reference the newly uploaded KML file.

LG constantly listens to /tmp/kmls.txt to know which KMLs it should load and render.

Once this file is updated with the correct URL, LG refreshes its visualization and displays the new overlay on the screen.

This overlay can contain text, images, branding, or any interactive elements supported by KML.

## 🚶 Step-by-Step Execution Walkthrough
Below is a breakdown of how the full pipeline works — from user input to immersive visual output on Liquid Galaxy.

**1️⃣ User Input**
The user initiates a query through the Flutter application’s interface, such as:


**"Tell me about the Colosseum in Rome."**
This query is intended to:

Ask the AI for contextual information

Trigger a visual response that flies to the specified location and overlays a summary

## 2️⃣ AI Processing (Gemini Pro)
Once the user submits a query, the following steps occur:

The app sends the query to the Google Gemini Pro AI model using the Gemini API.

Gemini analyzes the natural language, detects the location (e.g., "Colosseum in Rome"), and understands the context.

It then generates a rich and informative response, including historical facts, cultural importance, geographical data, and more.

The AI’s response is then returned to the app for visualization preparation.

## 3️⃣ App Execution & File Generation
With the AI response in hand, the app performs the following actions:

## 📄 KML File Creation
The response is embedded in a KML file using the <ScreenOverlay> element, allowing it to be shown as an on-screen text block in LG.

## 🌍 Fly-To Location Setup
The destination is written into /tmp/query.txt to instruct LG to zoom into the appropriate place on Earth.

## 🔐 SSH Uploads
The app uses SSH and SCP to:

Upload the KML file to /var/www/html/kmls/

Update /tmp/kmls.txt with the KML URL

Write the fly-to command into /tmp/query.txt

All of these steps happen automatically in the background, creating a smooth and intelligent visualization workflow.

## 4️⃣ Liquid Galaxy Visualization Output
Once the files have been uploaded and references updated:

**📍 The Liquid Galaxy cluster animates a fly-to motion to the geographic coordinates extracted by Gemini AI.**

**🖼️ The KML response file is loaded, and the AI-generated response is displayed as an overlay in a designated part of the screen (typically top-left or bottom-left).**

**✨ The user experiences a dynamic, narrated tour of the requested location, powered by AI and visualized in a stunning 3D globe interface.**

**🧪 Sample AI Query Prompts**
Try using the following prompts in your app to see the system in action:


## 🧠 Prompt	💡 Effect
**🏛️ Tell me about the Colosseum	Flies to Rome and overlays detailed facts**
**🌋 Where is Mount Fuji?	Zooms into Japan and displays its history**
**🗽 Give me facts about the Statue of Liberty	Centers on New York and shows cultural info**
**🏞️ Zoom into the Grand Canyon and explain its formation	Animates to the Grand Canyon with geology facts**

Each prompt triggers the following sequence:

AI understands and processes the text

Location coordinates are extracted

Fly-to animation and overlay are rendered on LG


<div align="center">
  <img src="https://github.com/user-attachments/assets/aa30391c-f751-4ead-ae10-5a6fcb57e25d" alt="Centered Image"  height=1000 width =500 />
</div>


## Installation Setup
**Clone the Repository**
```bash
git clone https://github.com/your-username/KISS-App.git
cd KISS-App.git
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







