# AI Features Detailed Comparison

## Overview

Both the **Mobile App** and **Website** have AI features, but with different implementations and feature sets.

---

## 📱 Mobile App AI Features

### Dedicated AI Screens (6 Screens)

| # | Feature | File | Implementation |
|---|---------|------|----------------|
| 1 | AI Chat | `ai_chat/ai_chat_screen.dart` | Dedicated full screen |
| 2 | AI Notes | `ai_notes/ai_notes_screen.dart` | Dedicated full screen |
| 3 | AI Quiz Generator | `ai_quiz_generator_screen.dart` | Dedicated full screen (32.8 KB) |
| 4 | Flashcards | `flashcards_screen.dart` | Dedicated full screen |
| 5 | Summarizer | `summarizer/summarizer_screen.dart` | Dedicated full screen |
| 6 | Voice to Text | `voice_to_text/voice_to_text_screen.dart` | Dedicated full screen |

### Mobile App AI Features Details

#### 1. AI Chat Screen
- Real-time chat with AI assistant
- Context awareness (knows current course)
- File upload support
- Search chat history
- Clear history option

#### 2. AI Notes Screen
- Generate notes from lecture recordings/slides
- Edit and refine notes
- Export to PDF
- Search and organize notes

#### 3. AI Quiz Generator Screen (32.8 KB - Large File)
- Generate quizzes from course content
- Difficulty selection
- Topic selection
- Question types:
  - Multiple choice
  - True/False
  - Short answer
- Time tracking
- Progress indication
- Quiz results/scoring

#### 4. Flashcards Screen
**Course Selector (5 courses):**
- Data Structures (📊)
- Algorithms (⚙️)
- Machine Learning (🤖)
- Web Development (🌐)
- Database Design (💾)

**Features:**
- Shuffle button
- Stats: Progress, Known, Review
- Flip animation
- "Known" button (green)
- "Review" button (orange)
- Generate new set with weak topics option

**Sample Cards:**
1. What is a Linked List?
2. Time complexity of binary search (O(log n))
3. Stack vs Queue (LIFO vs FIFO)
4. What is a hash table?
5. What is a tree in data structures?

#### 5. Summarizer Screen
- Paste or upload text/PDF
- Generate summary
- Adjustable summary length
- Copy summary
- Export options

#### 6. Voice to Text Screen
- Record audio
- Real-time transcription
- Language selection
- Edit transcribed text
- Export/save notes

---

## 💻 Website AI Features

### Modular Component (`AIFeatures/` Directory)

**Files Structure:**
```
AIFeatures/
├── contentTypes.ts
├── data.ts
├── features/
│   ├── ChatbotContent.tsx
│   ├── FeedbackContent.tsx
│   ├── FlashcardsContent.tsx
│   ├── ImageToTextContent.tsx
│   ├── index.tsx
│   ├── QuizContent.tsx
│   ├── RecommendationContent.tsx
│   ├── SummarizerContent.tsx
│   └── VoiceContent.tsx
├── index.tsx
├── types.ts
└── ui/
```

### Website AI Features (8 Features)

| # | Feature | File | Usage Stats |
|---|---------|------|-------------|
| 1 | Study Companion (Chatbot) | `ChatbotContent.tsx` | 156 times (Most Used) |
| 2 | Smart Recommender | `RecommendationContent.tsx` | 89 times |
| 3 | Voice Transcriber | `VoiceContent.tsx` | 67 times |
| 4 | Smart Summarizer | `SummarizerContent.tsx` | 45 times (Popular) |
| 5 | Smart Flashcards | `FlashcardsContent.tsx` | 34 times (New) |
| 6 | Writing Assistant (Feedback) | `FeedbackContent.tsx` | 32 times |
| 7 | Quiz Generator | `QuizContent.tsx` | 28 times (New) |
| 8 | OCR Scanner (Image-to-Text) | `ImageToTextContent.tsx` | 23 times |

### Website AI Features Details

#### 1. Study Companion (Chatbot) 🟣
- 24/7 AI Learning Assistant
- **Features:**
  - 24/7 Availability
  - Multi-Subject Support
  - Context Memory
- Usage: 156 times (Most Used)

#### 2. Smart Recommender 🟠
- Personalized Learning Path
- **Features:**
  - AI Matching
  - Progress Tracking
  - Resource Library
- Usage: 89 times

#### 3. Voice Transcriber 🔴
- Smart Audio to Text
- **Features:**
  - Real-time Processing
  - Multi-language Support
  - Speaker Detection
- Usage: 67 times

#### 4. Smart Summarizer 🔵
- Intelligent Content Condensing
- **Features:**
  - PDF & DOCX Support
  - Key Points Extraction
  - Smart Highlighting
- Usage: 45 times (Popular)

#### 5. Smart Flashcards 🟦
- AI-Powered Memory Cards
- **Features:**
  - Auto-Generation
  - Spaced Repetition
  - Progress Tracking
- Usage: 34 times (New)

#### 6. Writing Assistant (Feedback) 🟢
- Professional Feedback Engine
- **Features:**
  - Grammar Check
  - Style Enhancement
  - Plagiarism Detection
- Usage: 32 times

#### 7. Quiz Generator 🟣
- Adaptive Learning Assessment
- **Features:**
  - Adaptive Difficulty
  - Instant Grading
  - Performance Analytics
- Usage: 28 times (New)

#### 8. OCR Scanner (Image-to-Text) 🔷
- Visual Text Extraction
- **Features:**
  - Handwriting Support
  - Multi-format
  - Batch Processing
- Usage: 23 times

**Total Usage:** 474 sessions across all features

---

## 🔄 Feature Comparison Table

| AI Feature | Mobile App | Website | Comparison |
|------------|:----------:|:-------:|------------|
| **AI Chat/Chatbot** | ✅ Dedicated screen | ✅ Study Companion | Both have |
| **AI Notes** | ✅ Dedicated screen | ❌ | **MOBILE ONLY** |
| **Quiz Generator** | ✅ Dedicated screen | ✅ QuizContent | Both have |
| **Flashcards** | ✅ Dedicated screen | ✅ FlashcardsContent | Both have |
| **Summarizer** | ✅ Dedicated screen | ✅ SummarizerContent | Both have |
| **Voice to Text** | ✅ Dedicated screen | ✅ VoiceContent | Both have |
| **Smart Recommender** | ❌ | ✅ RecommendationContent | **WEBSITE ONLY** |
| **Writing Assistant** | ❌ | ✅ FeedbackContent | **WEBSITE ONLY** |
| **OCR Scanner** | ❌ | ✅ ImageToTextContent | **WEBSITE ONLY** |

---

## 📊 Detailed Feature Differences

### AI Chat/Study Companion

| Feature | Mobile App | Website |
|---------|:----------:|:-------:|
| Dedicated screen | ✅ | ❌ (Modal/Tab) |
| 24/7 availability | ✅ | ✅ |
| Context awareness | ✅ | ✅ |
| File upload | ✅ | ❓ |
| Search history | ✅ | ❓ |
| Clear history | ✅ | ❓ |
| Multi-subject support | ❓ | ✅ |
| Context memory | ❓ | ✅ |

### Quiz Generator

| Feature | Mobile App | Website |
|---------|:----------:|:-------:|
| Dedicated screen | ✅ | ❌ (Modal/Tab) |
| Difficulty selection | ✅ | ✅ (Adaptive) |
| Topic selection | ✅ | ❓ |
| Multiple choice | ✅ | ✅ |
| True/False | ✅ | ✅ |
| Short answer | ✅ | ❓ |
| Time tracking | ✅ | ❓ |
| Progress indication | ✅ | ❓ |
| Instant grading | ✅ | ✅ |
| Performance analytics | ❓ | ✅ |

### Flashcards

| Feature | Mobile App | Website |
|---------|:----------:|:-------:|
| Dedicated screen | ✅ | ❌ (Modal/Tab) |
| Course selector | ✅ | ❓ |
| Shuffle | ✅ | ❓ |
| Known/Review buttons | ✅ | ❓ |
| Generate new set | ✅ | ❓ |
| Weak topics option | ✅ | ❓ |
| Auto-generation | ❓ | ✅ |
| Spaced repetition | ✅ | ✅ |
| Progress tracking | ✅ | ✅ |

### Summarizer

| Feature | Mobile App | Website |
|---------|:----------:|:-------:|
| Dedicated screen | ✅ | ❌ (Modal/Tab) |
| Paste text | ✅ | ✅ |
| Upload PDF | ✅ | ✅ |
| Upload DOCX | ❓ | ✅ |
| Adjustable length | ✅ | ❓ |
| Copy summary | ✅ | ❓ |
| Export options | ✅ | ❓ |
| Key points extraction | ❓ | ✅ |
| Smart highlighting | ❓ | ✅ |

### Voice to Text

| Feature | Mobile App | Website |
|---------|:----------:|:-------:|
| Dedicated screen | ✅ | ❌ (Modal/Tab) |
| Record audio | ✅ | ✅ |
| Real-time transcription | ✅ | ✅ |
| Language selection | ✅ | ✅ |
| Edit text | ✅ | ❓ |
| Export/save | ✅ | ❓ |
| Speaker detection | ❓ | ✅ |

---

## 🔴 Features ONLY in Mobile App

| # | Feature | Description |
|---|---------|-------------|
| 1 | **AI Notes** | Generate notes from lectures, edit, export to PDF |
| 2 | **Quiz Taking Interface** | Dedicated `quiz_questions_screen.dart` for taking quizzes |

---

## 🔵 Features ONLY in Website

| # | Feature | Description |
|---|---------|-------------|
| 1 | **Smart Recommender** | AI matching, progress tracking, resource library |
| 2 | **Writing Assistant** | Grammar check, style enhancement, plagiarism detection |
| 3 | **OCR Scanner** | Handwriting support, multi-format, batch processing |
| 4 | **Usage Statistics** | Shows usage count for each AI feature |

---

## 🎯 Implementation Differences

### Mobile App
- **6 dedicated full screens** for AI features
- Each feature has its own navigation entry
- Can access AI features from drawer/navigation
- Full-screen immersive experience
- More focused user flow per feature

### Website
- **1 modular component** with tabs/cards
- All 8 features in one dashboard section
- Cards with feature icons and usage stats
- Click card to open feature modal/tab
- More compact, all-in-one approach

---

## ✅ Recommendations

### For Mobile App Team

1. **Add Smart Recommender** - AI learning path recommendations
2. **Add Writing Assistant** - Grammar and plagiarism checking
3. **Add OCR Scanner** - Image to text for handwritten notes
4. **Add Usage Statistics** - Track feature usage

### For Website Team

1. **Add AI Notes** - Dedicated notes generation feature
2. **Make features full-screen** - Option to expand to full view
3. **Add Quiz Taking Interface** - Dedicated quiz-taking experience
4. **Add Course Selector** - In flashcards like mobile

---

## 📈 Summary Statistics

| Metric | Mobile App | Website |
|--------|------------|---------|
| Total AI Features | 6 | 8 |
| Dedicated Screens | 6 | 0 (all modular) |
| Unique Features | 2 | 3 |
| Shared Features | 4 | 5 |
| Usage Tracking | ❌ | ✅ |

---

*Last Updated: February 2026*
