# minimal-workout-log

# **Minimal Workout Log**

A clean, ultra-minimal workout logging app built for iOS using SwiftUI, SwiftData, and CloudKit.
The goal is to let users track their workouts with zero clutter and maximum clarity.

---

## **Features (v1)**

### **Workouts**

* Create custom workout templates
* Add exercises with sets and optional rep ranges
* Start workouts directly from templates
* Quickly log reps and weight with a large, centered interface
* Compare today’s numbers to last session
* Add notes for each exercise
* Perform extra sets (“Do More”), swap exercises, or “Squeeze one in”
* Skip exercises when needed

### **Summary**

After each workout, users see:

* Total session time
* Estimated work & rest time
* Total weight lifted
* Best set of the day
* PR notifications
* Exercise-by-exercise volume breakdown
* Notes summary
* Session mood selector
* “Review changes” button to update the template if the user swapped/squeezed in exercises

---

## **Home Screen**

Centered, minimal UI:

* “Stats” button at the top
* “Workouts” in the middle
* Scrollable list of templates (max 3 visible)
* Large “+” to create new template
* Gear icon for settings

---

## **Data Model (simplified)**

* **UserSettings**

  * auth mode (iCloud or local)
  * weight unit (kg/lb)

* **WorkoutTemplate**

  * name
  * exercises

* **TemplateExercise**

  * name
  * planned sets
  * optional rep range

* **WorkoutSession**

  * start/end time
  * linked template
  * total stats, notes, mood

* **ExerciseSession**

  * logged sets
  * notes
  * swapped/squeezed flag

* **WorkoutSet**

  * reps, weight, timestamp
  * extra-set flag

---

## **Tech Stack**

* **SwiftUI**
* **SwiftData** for local storage
* **CloudKit** for iCloud sync
* Offline-first design

---

## **Roadmap (future versions)**

* Apple Watch companion app
* Detailed charts in Stats
* HealthKit integration
* Smarter PR tracking
* Export / import

---

## **Setup**

1. Clone the repo
2. Open the project in Xcode 15+
3. Ensure iCloud + CloudKit is enabled
4. Build & run on iPhone (simulator or device)

---

If you want, I can also generate:

* A LICENSE file
* A CONTRIBUTING.md
* A full Codex developer prompt based on our entire app spec.
