import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:aura_study/core/services/ai_service.dart';
import 'package:aura_study/features/notes/domain/note_model.dart';
import 'package:aura_study/features/quiz/domain/quiz_model.dart';
import 'package:aura_study/features/flashcards/domain/flashcard_model.dart';

class GeminiAIService implements AIService {
  final String _apiKey;
  late final GenerativeModel _model;
  final MockAIService _fallback = MockAIService();

  GeminiAIService(this._apiKey) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: _apiKey,
      systemInstruction: Content.system(
        "You are Aura Tutor, a futuristic, supportive, and precise academic AI mentor integrated into the Aura Study mobile app. "
        "Your goal is to help scholars organize, synthesize, and absorb cognitive knowledge sheets. "
        "Keep your tone highly scientific, encouraging, helpful, and premium (scifi aesthetic but academic). "
        "Ensure your responses use beautiful clean markdown. Avoid generic fluffy paragraphs; prefer structured, bulleted lists and bold key phrases."
      ),
    );
  }

  @override
  bool get isMockMode => false;

  @override
  Future<String> summarizeNote(String title, String content) async {
    try {
      final prompt = "Generate a structured, bulleted markdown summary of the study note titled '$title'. Here is the content:\n\n$content\n\nReturn only the markdown bullet points starting with a header '## 🌟 AI Cognitive Summary'.";
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? await _fallback.summarizeNote(title, content);
    } catch (e) {
      debugPrint("AURA AI WARNING: Gemini summarizer failed, falling back to mock: $e");
      return _fallback.summarizeNote(title, content);
    }
  }

  @override
  Future<List<String>> suggestTags(String title, String content) async {
    try {
      final prompt = "Analyze the title '$title' and content below. Suggest exactly 3 to 5 academic and subject tags (single words, lowercase, no hashtags, separated by commas) that align with this study content. Content:\n\n$content";
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        final suggested = text.split(',')
            .map((t) => t.replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '').trim().toLowerCase())
            .where((t) => t.isNotEmpty)
            .toList();
        if (suggested.isNotEmpty) return suggested;
      }
      return _fallback.suggestTags(title, content);
    } catch (e) {
      debugPrint("AURA AI WARNING: Gemini tag suggestion failed, falling back to mock: $e");
      return _fallback.suggestTags(title, content);
    }
  }

  @override
  Future<String> chatWithTutor(String message, String? contextNote) async {
    try {
      final contextPrompt = contextNote != null && contextNote.isNotEmpty
          ? "ACTIVE STUDY NOTE CONTEXT:\n$contextNote\n\n"
          : "";
      final prompt = "${contextPrompt}Scholar's Query: $message\n\nRespond to the query accurately, using clear scifi-academic formatting, clean markdown, bullet points for complex topics, and a supportive tone. Keep the answer relatively concise (under 250 words) but thorough.";
      final response = await _model.generateContent([Content.text(prompt)]);
      return response.text ?? await _fallback.chatWithTutor(message, contextNote);
    } catch (e) {
      debugPrint("AURA AI WARNING: Gemini tutor chat failed, falling back to mock: $e");
      return _fallback.chatWithTutor(message, contextNote);
    }
  }

  @override
  Future<StudyNote> analyzePDF(String pdfName, String pdfUrl) async {
    try {
      final prompt = "You are Aura Tutor, a supportive scifi academic AI. The scholar has uploaded a PDF document named '$pdfName' (located at '$pdfUrl'). "
          "Please generate a comprehensive, highly structured study guide note based on this topic. "
          "Format your response as a single valid study note in this EXACT structure:\n\n"
          "## 🌟 AI Cognitive Analysis: $pdfName\n\n"
          "### 🧠 Executive Subject Summary\n"
          "[Insert synthesis of topic here]\n\n"
          "### 🔬 Core Theoretical Pillars\n"
          "[Insert bullet points detailing core pillars here]\n\n"
          "### 📝 Essential Formulas & Principles\n"
          "[Insert formulas, formatted using standard LaTeX or clear markdown math formatting here]\n\n"
          "### 📅 Recommended Study Schedule\n"
          "[Insert 3 session outline here]\n\n"
          "Please suggest exactly 3-5 tags (lowercase, comma separated) at the very end of your response under a header '---TAGS---' (e.g. ---TAGS--- math, algebra, limits). "
          "Also suggest a single word academic category at the very end under '---CATEGORY---' (e.g. ---CATEGORY--- Math).";
      
      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        String content = text;
        List<String> tags = ["pdf-ingest", "study-guide", "ai-generated"];
        String category = "Study Guide";
        
        if (content.contains("---TAGS---")) {
          final parts = content.split("---TAGS---");
          content = parts[0].trim();
          var tagPart = parts[1];
          if (tagPart.contains("---CATEGORY---")) {
            final subParts = tagPart.split("---CATEGORY---");
            tagPart = subParts[0].trim();
            category = subParts[1].trim();
          }
          final parsedTags = tagPart.split(',')
              .map((t) => t.replaceAll(RegExp(r'[^a-zA-Z0-9-]'), '').trim().toLowerCase())
              .where((t) => t.isNotEmpty)
              .toList();
          if (parsedTags.isNotEmpty) tags.addAll(parsedTags);
        } else if (content.contains("---CATEGORY---")) {
          final parts = content.split("---CATEGORY---");
          content = parts[0].trim();
          category = parts[1].trim();
        }
        
        final cleanName = pdfName.replaceAll('.pdf', '').replaceAll('_', ' ').replaceAll('-', ' ');
        final now = DateTime.now();
        
        return StudyNote(
          id: 'pdf-${now.millisecondsSinceEpoch}',
          title: "Study Guide: $cleanName",
          content: content,
          category: category,
          tags: tags.toSet().toList(),
          isPinned: false,
          colorHex: "0xFF00F0FF", // Cyan
          createdAt: now,
          updatedAt: now,
        );
      }
      return _fallback.analyzePDF(pdfName, pdfUrl);
    } catch (e) {
      debugPrint("AURA AI WARNING: Gemini PDF analysis failed, falling back to mock: $e");
      return _fallback.analyzePDF(pdfName, pdfUrl);
    }
  }

  @override
  Future<StudyNote> transcribeVoice(String speechText, String subjectArea) async {
    try {
      final textToUse = speechText.trim().isEmpty 
          ? "Lecture on $subjectArea topics and standard configurations." 
          : speechText;
      
      final prompt = "You are Aura Tutor, a supportive academic AI. The scholar recorded a lecture note in the subject area '$subjectArea'. "
          "Raw captured speech text: '$textToUse'.\n\n"
          "Please generate a complete, structured study note. Format the response EXACTLY in this format:\n\n"
          "## 🎙️ Lecture Transcript\n"
          "*\"$textToUse\"*\n\n"
          "---\n\n"
          "## 🧠 AI Cognitive Synthesis: $subjectArea\n\n"
          "### 📋 Executive Takeaways\n"
          "[Insert bullet points detailing executive takeaways here]\n\n"
          "### 🔬 Deep Dive Analysis\n"
          "[Insert deep dive explanation including theoretical background here]\n\n"
          "Keep the content structured and clean using sci-fi academic style markdown.";

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        final now = DateTime.now();
        return StudyNote(
          id: 'voice-${now.millisecondsSinceEpoch}',
          title: "Voice Capture: $subjectArea Lecture",
          content: text,
          category: subjectArea,
          tags: ["voice-note", "ai-generated", subjectArea.toLowerCase()],
          isPinned: false,
          colorHex: "0xFFFF007A", // Pink
          createdAt: now,
          updatedAt: now,
        );
      }
      return _fallback.transcribeVoice(speechText, subjectArea);
    } catch (e) {
      debugPrint("AURA AI WARNING: Gemini Voice transcription failed, falling back to mock: $e");
      return _fallback.transcribeVoice(speechText, subjectArea);
    }
  }

  @override
  Future<List<QuizQuestion>> generateQuiz(String title, String content, {int count = 5}) async {
    try {
      final prompt = "Generate a multiple-choice quiz with exactly $count questions based on the topic '$title' and the study content below.\n\n"
          "Content:\n$content\n\n"
          "You MUST respond ONLY with a raw, valid JSON array of objects. Do not include markdown code block syntax (like ```json ... ```) or any explanation. Simply return the valid JSON array.\n"
          "Each object in the array MUST have the exact following structure:\n"
          "{\n"
          "  \"question\": \"Question text here\",\n"
          "  \"options\": [\"Option A\", \"Option B\", \"Option C\", \"Option D\"],\n"
          "  \"correctIndex\": 0,\n"
          "  \"explanation\": \"Why Option A is correct explanation...\"\n"
          "}\n"
          "Ensure correctIndex is an integer from 0 to 3 matching the index of the correct option.";

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        var cleanJson = text.trim();
        if (cleanJson.startsWith("```")) {
          cleanJson = cleanJson.replaceAll(RegExp(r'^```json\s*|^```\s*|```$'), '');
        }
        cleanJson = cleanJson.trim();

        final List<dynamic> list = jsonDecode(cleanJson);
        final questions = list.map((q) => QuizQuestion.fromJson(Map<String, dynamic>.from(q))).toList();
        if (questions.isNotEmpty) return questions;
      }
      return _fallback.generateQuiz(title, content, count: count);
    } catch (e) {
      debugPrint("AURA AI WARNING: Gemini quiz generator failed, falling back to mock: $e");
      return _fallback.generateQuiz(title, content, count: count);
    }
  }

  @override
  Future<List<Flashcard>> generateFlashcards(String title, String content) async {
    try {
      final prompt = "Generate exactly 6 active-recall study flashcards based on the topic '$title' and the study content below.\n\n"
          "Content:\n$content\n\n"
          "You MUST respond ONLY with a raw, valid JSON array of objects. Do not include markdown code block syntax (like ```json ... ```) or any explanation. Simply return the valid JSON array.\n"
          "Each object in the array MUST have the exact following structure:\n"
          "{\n"
          "  \"id\": \"unique_card_id_1\",\n"
          "  \"frontText\": \"Question/term to recall here\",\n"
          "  \"backText\": \"Answer/explanation here\",\n"
          "  \"category\": \"$title\"\n"
          "}\n";

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        var cleanJson = text.trim();
        if (cleanJson.startsWith("```")) {
          cleanJson = cleanJson.replaceAll(RegExp(r'^```json\s*|^```\s*|```$'), '');
        }
        cleanJson = cleanJson.trim();

        final List<dynamic> list = jsonDecode(cleanJson);
        final cards = list.map((c) => Flashcard.fromJson(Map<String, dynamic>.from(c))).toList();
        if (cards.isNotEmpty) return cards;
      }
      return _fallback.generateFlashcards(title, content);
    } catch (e) {
      debugPrint("AURA AI WARNING: Gemini flashcard generator failed, falling back to mock: $e");
      return _fallback.generateFlashcards(title, content);
    }
  }

  @override
  Future<List<Map<String, dynamic>>> generateStudySchedule(String title, String content) async {
    try {
      final prompt = "Generate a highly structured recommended study schedule with exactly 2 to 3 study tasks based on the topic '$title' and the study content below.\n\n"
          "Content:\n$content\n\n"
          "You MUST respond ONLY with a raw, valid JSON array of objects. Do not include markdown code block syntax (like ```json ... ```) or any explanation. Simply return the valid JSON array.\n"
          "Each object in the array MUST have the exact following structure:\n"
          "{\n"
          "  \"title\": \"Clear concise task title (e.g., Review Eigenvector formulas)\",\n"
          "  \"details\": \"Detailed action step or bulleted sub-task details\",\n"
          "  \"category\": \"Physics or Chemistry or Mathematics or General\",\n"
          "  \"hoursFromNow\": 2,\n"
          "  \"reminderEnabled\": true\n"
          "}\n"
          "Ensure that hoursFromNow specifies the positive integer number of hours offset from now to schedule this task (e.g. 2, 24, 48).";

      final response = await _model.generateContent([Content.text(prompt)]);
      final text = response.text;
      if (text != null && text.isNotEmpty) {
        var cleanJson = text.trim();
        if (cleanJson.startsWith("```")) {
          cleanJson = cleanJson.replaceAll(RegExp(r'^```json\s*|^```\s*|```$'), '');
        }
        cleanJson = cleanJson.trim();

        final List<dynamic> list = jsonDecode(cleanJson);
        final List<Map<String, dynamic>> tasks = list.map((t) => Map<String, dynamic>.from(t)).toList();
        if (tasks.isNotEmpty) return tasks;
      }
      return _fallback.generateStudySchedule(title, content);
    } catch (e) {
      debugPrint("AURA AI WARNING: Gemini schedule generator failed, falling back to mock: $e");
      return _fallback.generateStudySchedule(title, content);
    }
  }
}
