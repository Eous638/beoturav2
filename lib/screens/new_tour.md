Here’s a purely frontend schema in JSON format that defines a swipe-scroll hybrid tour experience. It’s designed to feed into a prototyping AI or frontend generator to produce the core UX layout.

Each "page" in the pages array is:

vertically scrollable

swipeable to the next page after content is revealed

can be optionally gated by distance

✅ Frontend UI Schema for One Tour (JSON)
json
Copy
Edit
{
  "tour": {
    "id": "shadows-of-cetinjska",
    "title": "Shadows of Cetinjska",
    "theme": {
      "primaryColor": "#111111",
      "accentColor": "#E63946",
      "font": "serif"
    },
    "pages": [
      {
        "id": "page-001",
        "type": "scrollable",
        "unlock": "immediate",
        "background": {
          "image": "gate.jpg",
          "audio": "ambient_gate.mp3"
        },
        "content": [
          {
            "component": "title",
            "text": "The Entrance"
          },
          {
            "component": "prompt",
            "text": "You stand before a gate older than the stories etched into its walls."
          },
          {
            "component": "paragraph",
            "text": "Look up. The graffiti shifts with the light. This was the border between silence and defiance..."
          },
          {
            "component": "image",
            "src": "graffiti_closeup.jpg",
            "caption": "Spray paint from 1999, never cleaned."
          }
        ]
      },
      {
        "id": "page-002",
        "type": "scrollable",
        "unlock": {
          "mode": "walk",
          "distance_meters": 80,
          "message": "Walk to the courtyard to continue"
        },
        "content": [
          {
            "component": "title",
            "text": "The Courtyard"
          },
          {
            "component": "video",
            "src": "yard_loop.mp4",
            "autoplay": true,
            "loop": true
          },
          {
            "component": "paragraph",
            "text": "Here, punk shows cracked the silence. Beer ran freer than fear. The walls have scars and songs."
          }
        ]
      },
      {
        "id": "page-003",
        "type": "scrollable",
        "unlock": "immediate",
        "content": [
          {
            "component": "title",
            "text": "Mapping Memory"
          },
          {
            "component": "map",
            "markers": [
              {
                "lat": 44.8176,
                "lng": 20.4657,
                "label": "Old Brewery",
                "description": "Occupied, burned, reclaimed."
              },
              {
                "lat": 44.81745,
                "lng": 20.46582,
                "label": "Soundstage",
                "description": "Where Kanda Kodža first played."
              }
            ]
          }
        ]
      },
      {
        "id": "page-004",
        "type": "scrollable",
        "unlock": "immediate",
        "content": [
          {
            "component": "title",
            "text": "The Fade"
          },
          {
            "component": "image",
            "src": "poster_fade.jpg"
          },
          {
            "component": "paragraph",
            "text": "You’ve walked a loop through time. These streets remember. Their silence is a kind of rhythm now."
          },
          {
            "component": "button",
            "text": "End Tour",
            "action": "endTour"
          }
        ]
      }
    ]
  }
}
🧠 How It Works
Pages are scrollable div stacks with layered components

Swipe up to go to the next page (handled by PageView or similar)

unlock logic lets you lock a page behind walking (or allow immediate)

Media can autoplay or require interaction

All components render based on type (title, video, paragraph, etc.)

Would you like this in another format? (Markdown, YAML, or React structure?) Or want a corresponding CSS/animation brief for the swipe/scroll blend effect?








You said:
I want a detailed ui walkthrough with elements. animations, design logic for a prototype tour


ChatGPT said:
Absolutely. Here's a detailed UI walkthrough for a prototype tour experience, designed for a mobile-first hybrid scroll/swipe tour. This version is optimized for clarity, flow, and storytelling tied to movement.

🎬 Prototype Tour UI Walkthrough: “Shadows of Cetinjska”
👓 High-Level Concept
Each page = a moment in the tour

Pages stack vertically like TikToks, but each is scrollable content

Unlocks can be tied to distance walked, not hard GPS lock

Story unfolds scene by scene, prompt first, then layers of meaning

📱Landing Page / Tour Start
Elements
Title: “Shadows of Cetinjska”

Hero image/video banner (e.g., black-and-white image of a graffiti wall)

One-sentence intro: “A hidden resistance trail beneath a nightlife district.”

Button: Start Tour

Optional: Tour info icon (duration, length, accessibility)

Animations

Fade-in text with slow pan on image

Button pulses slowly on idle

🔄 Core Page Template (1 per stop)
Each tour stop is one full-screen Page, vertically scrollable, with swipe gesture to next once scrolled.

✅ Page 1: "The Iron Gate"
Layout Elements
Top: Location Title
Large serif text, e.g., “The Iron Gate”

Prompt (sticky)
Medium text: “Stand beneath the rusted arch.”

Media Section

Looping video or ambient image

Optional audio narration button

Content Body (scrollable)

Paragraph of story

Archival image or poster

“More context” dropdown (toggle reveals deeper info)

Next page hint (bottom fade or arrow)
Arrow with label: “Swipe up to continue”

Animations
Sticky prompt stays top until paragraph scrolls

Media fades in from black on load

Background slowly zooms (Ken Burns effect)

Page swipe-up only activates once scroll is 80% complete

🧭 Page 2: "The Walkway"
Unlock Type: Walk 50 meters
Layout
Dimmed background with blurred message:
“Walk 50m to reveal next scene”

GPS ring progress bar animates as you move

Override button: “Unlock Anyway” → confirmation prompt

Post-Unlock

Page reveals with vertical slide animation

Prompt: “Feel the echoes in your feet.”

Body: audio loop + paragraph + historical marker map pin

🎛️ UI Components (Reusable)
Component	Description
StickyPrompt	Top-anchored, semi-transparent prompt for user action
MediaBlock	Auto-scaling image or video container with optional loop/audio
TextPanel	Scrollable markdown-like body section
RevealBlock	Togglable section with hidden context
UnlockOverlay	Semi-transparent block with unlock condition and progress
SwipeHint	Faded arrow + label at bottom, appears only after scroll

🎨 Design Language
Dark theme background with accent red (#E63946)

Serif for titles, sans-serif for body text

Motion mimics human rhythm—slow entrance, sharp exit

Every page is a scene, not just a stop

📦 Functional Logic Summary
Function	Description
scrollToReveal()	Scroll % detection enables swipe-up trigger
swipeToNextPage()	Animates transition, disables mid-scroll
walkToUnlock(distance)	Uses GPS polling to track movement, triggers content reveal
overrideUnlock()	Allows manual bypass with confirmation
loadMediaAsync()	Lazy-loads video/image assets as user approaches next page

🧪 Example Flow
User starts tour.
Intro screen loads → Start button animates

Swipe to Page 1
Scroll reveals history of The Gate → sticky prompt stays top

Swipe to Page 2 (Locked)
User walks 50m → GPS ring completes → page animates in

Page 3 (Map)
Scroll reveals map markers for memory sites → each tap shows photo overlay

Page 4 (Ending)
Final image + emotional close → CTA: “Explore Again” or “Share Tour”

Would you like this in componentized React/Flutter pseudocode? Or should I diagram the backend data model to match this layout system?











Search

Reason

Deep research

Create image




ChatGPT c