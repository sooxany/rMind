# rMind: Interview Response Analysis App using rPPG

**rMind** is a mobile-based interview response analysis platform that leverages **remote photoplethysmography (rPPG)** technology to non-invasively measure heart rate and physical signals from facial videos.  
The system visualizes physiological responses such as **heart rate variability, blink frequency, and body movement** to help users understand their stress and engagement levels during mock interviews.

---

## 🔍 Project Overview

- **Purpose**: To build a contactless physiological feedback system for interview preparation using facial video analysis.
- **Core Feature**: Real-time heart rate estimation using rPPG without any physical sensor.
- **Platform**: Flutter-based mobile frontend + FastAPI-based backend server.

---

## 🎯 Key Features

- 📷 **Video Upload**: Users can upload recorded interview response videos via mobile app.
- 💓 **rPPG Heart Rate Analysis**: Extracts green-channel pulse signals from facial regions.
- 👁️ **Blink Detection**: Detects and visualizes eye blink frequency per second.
- 🧍 **Body Motion Visualization**: Detects abrupt head/shoulder movements using face landmarks.
- 📊 **Result Visualization**: Displays 3 analysis graphs (BPM curve, blink timeline, motion score) for each video.

---

## ⚙️ Technologies Used

- **Frontend**: Flutter, Dart
- **Backend**: FastAPI, Python
- **Signal Processing**: OpenCV, NumPy, SciPy
- **Face Detection**: Haar Cascade, Dlib (68-point landmarks)
- **rPPG Algorithms**: CHROM, POS, ICA
- **Heart Rate Estimation**: Fourier, Wavelet, Interbeat Interval methods
- **Data Format**: CSV for raw signal logging, PNG for result visualization

---

## 🧪 Experiment Summary

A series of test scenarios were conducted to simulate different psychological and physiological interview reactions:

1. High initial heart rate → gradual relaxation
2. Calm start → sudden BPM spike and fixed high state
3. Body motion-induced irregular BPM fluctuation → stabilization
4. Two-step BPM spikes (physical activity + subject swap)
5. Persistent erratic BPM pattern from dynamic subject

rMind successfully captured all significant patterns and visualized them as time-series graphs, offering useful insights into the user’s interview behavior.
