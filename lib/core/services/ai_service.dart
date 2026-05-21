import 'dart:async';
import 'package:aura_study/features/notes/domain/note_model.dart';
import 'package:aura_study/features/quiz/domain/quiz_model.dart';
import 'package:aura_study/features/flashcards/domain/flashcard_model.dart';

abstract class AIService {
  Future<String> summarizeNote(String title, String content);
  Future<List<String>> suggestTags(String title, String content);
  Future<String> chatWithTutor(String message, String? contextNote);
  Future<StudyNote> analyzePDF(String pdfName, String pdfUrl);
  Future<StudyNote> transcribeVoice(String speechText, String subjectArea);
  Future<List<QuizQuestion>> generateQuiz(String title, String content, {int count = 5});
  Future<List<Flashcard>> generateFlashcards(String title, String content);
  Future<List<Map<String, dynamic>>> generateStudySchedule(String title, String content);
  bool get isMockMode;
}

class MockAIService implements AIService {
  @override
  bool get isMockMode => true;

  @override
  Future<String> summarizeNote(String title, String content) async {
    // Simulate scifi cognitive delay
    await Future.delayed(const Duration(milliseconds: 1500));
    
    return """## 🌟 AI Cognitive Summary: $title
 
* **Core Focus**: Structured exploration of academic definitions and mechanisms inside this $title record.
* **Key Synthesized Findings**:
  - The content outlines core principles, formulas, and relevant details.
  - Highlights essential structural rules designed to reinforce cognitive storage.
* **Tutor Directive**: Review these definitions regularly. Try generating dynamic flashcards inside the Quiz Center to test active recall.""";
  }

  @override
  Future<List<String>> suggestTags(String title, String content) async {
    await Future.delayed(const Duration(milliseconds: 800));
    
    final tags = <String>{"study", "aura-ai"};
    final lowerTitle = title.toLowerCase();
    final lowerContent = content.toLowerCase();

    if (lowerTitle.contains("physics") || lowerContent.contains("physics") || lowerContent.contains("quantum") || lowerContent.contains("wave")) {
      tags.addAll(["physics", "quantum", "equations"]);
    } else if (lowerTitle.contains("chemistry") || lowerContent.contains("organic") || lowerContent.contains("nomenclature")) {
      tags.addAll(["chemistry", "organic", "nomenclature"]);
    } else if (lowerTitle.contains("math") || lowerContent.contains("calculus") || lowerContent.contains("limits") || lowerContent.contains("integral")) {
      tags.addAll(["math", "calculus", "limits"]);
    } else {
      tags.addAll(["general", "recall"]);
    }
    
    return tags.toSet().toList();
  }

  @override
  Future<String> chatWithTutor(String message, String? contextNote) async {
    await Future.delayed(const Duration(milliseconds: 1200));

    final msg = message.toLowerCase();
    String tutorGreeting = "Greetings, scholar! I am Aura Tutor. ";
    
    if (contextNote != null && contextNote.trim().isNotEmpty) {
      tutorGreeting += "Analyzing your active study note context to align my responses...\n\n";
    }

    if (msg.contains("hello") || msg.contains("hi") || msg.contains("hey")) {
      return "${tutorGreeting}How may I assist your academic journey today? Feel free to ask me to analyze concepts, break down complex formulas, or quiz you on subjects.";
    } else if (msg.contains("physics") || msg.contains("thermodynamics") || msg.contains("quantum") || msg.contains("schrodinger")) {
      return "${tutorGreeting}Ah, the fascinating rules of physics! Newtonian mechanics, thermodynamics, and quantum configuration systems form the foundation of our physical world. For instance, the First Law of Thermodynamics states that energy cannot be created or destroyed, only transformed. What specific physics equation or concept shall we untangle?";
    } else if (msg.contains("chemistry") || msg.contains("organic") || msg.contains("iupac")) {
      return "${tutorGreeting}Organic Chemistry governs carbon-based molecules and functional compounds. Structuring molecules using IUPAC nomenclature helps categorize chains, roots, and priorities. Let me know if you would like me to explain prefix hierarchy or bond rules!";
    } else if (msg.contains("quiz") || msg.contains("test me") || msg.contains("question")) {
      return "${tutorGreeting}Excellent initiative! Let's perform a cognitive diagnostic check. Here is your question:\n\n*What is the name of the physics principle stating that two identical fermions cannot occupy the same quantum state simultaneously?* (Submit your reply!)";
    } else {
      return "${tutorGreeting}I have synthesized your query: '$message'. To accelerate your learning, remember to break down notes into clear visual frameworks. Would you like me to outline this specific concept in a structured format?";
    }
  }

  @override
  Future<StudyNote> analyzePDF(String pdfName, String pdfUrl) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final cleanName = pdfName.replaceAll('.pdf', '').replaceAll('_', ' ').replaceAll('-', ' ');
    final now = DateTime.now();
    
    final tags = ["pdf-ingest", "study-guide", "ai-generated"];
    final lowerName = cleanName.toLowerCase();
    
    String subject = "Study Guide";
    String formulaText = "";
    
    if (lowerName.contains("physics") || lowerName.contains("quantum") || lowerName.contains("mechanics")) {
      tags.addAll(["physics", "quantum"]);
      subject = "Physics";
      formulaText = r"* **Schrödinger Wave Equation**: "
          "\n"
          r"  $$i\hbar\frac{\partial}{\partial t}\Psi(\mathbf{r},t) = \hat{H}\Psi(\mathbf{r},t)$$"
          "\n"
          r"  *Governs the behavior of quantum mechanical systems.*";
    } else if (lowerName.contains("algebra") || lowerName.contains("linear") || lowerName.contains("calculus") || lowerName.contains("math")) {
      tags.addAll(["math", "algebra"]);
      subject = "Mathematics";
      formulaText = r"* **Eigenvalue Equation**: "
          "\n"
          r"  $$A\mathbf{x} = \lambda\mathbf{x}$$"
          "\n"
          r"  *Where $A$ is a square matrix, $\mathbf{x}$ is the eigenvector, and $\lambda$ is the eigenvalue.*";
    } else if (lowerName.contains("chem") || lowerName.contains("organic")) {
      tags.addAll(["chemistry", "organic"]);
      subject = "Chemistry";
      formulaText = r"* **Gibbs Free Energy Equation**: "
          "\n"
          r"  $$\Delta G = \Delta H - T\Delta S$$"
          "\n"
          r"  *Determines spontaneity of chemical reaction systems.*";
    } else {
      tags.addAll(["general", "academia"]);
      formulaText = r"* **Universal Retention Theory**: "
          "\n"
          r"  $$R(t) = e^{-\frac{t}{S}}$$"
          "\n"
          r"  *Where $R$ is memory retention, $t$ is time elapsed, and $S$ is strength of memory.*";
    }

    final content = """## 🌟 AI Cognitive Analysis: $pdfName
 
### 🧠 Executive Subject Summary
A synthesized academic review of the document **$pdfName** (Source: `$pdfUrl`). This knowledge profile has been extracted to optimize active recall parameters and simplify learning.
 
### 🔬 Core Theoretical Pillars
* **Pillar I: Fundamental Premises**: Analysis of foundational variables and initial definitions outline standard academic patterns in this study area.
* **Pillar II: Structured Methodologies**: Step-by-step examination of rules, transformations, and core configurations.
 
### 📝 Essential Formulas & Principles
$formulaText
* **The 80/20 Retention Rule**: Focus 80% of testing effort on the core 20% high-yield concepts.
 
### 📅 Recommended Study Schedule
1. **Session 1 (Day 1)**: Initial conceptual mapping and terminology indexing.
2. **Session 2 (Day 3)**: Formula practice and derivation mapping.
3. **Session 3 (Day 7)**: Interactive self-testing using the Quiz Center.
 
*Analyzed by Aura Study Cognitive Core.*""";

    return StudyNote(
      id: 'pdf-${now.millisecondsSinceEpoch}',
      title: "Study Guide: $cleanName",
      content: content,
      category: subject,
      tags: tags.toSet().toList(),
      isPinned: false,
      colorHex: "0xFF00F0FF", // Neon Cyan
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<StudyNote> transcribeVoice(String speechText, String subjectArea) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    
    final cleanSpeech = speechText.trim();
    final now = DateTime.now();
    
    final String transcriptionText;
    if (cleanSpeech.isEmpty) {
      if (subjectArea.toLowerCase() == "physics") {
        transcriptionText = "We are discussing the laws of thermodynamics, specifically entropy. In any closed system, the entropy or degree of disorder will always tend to increase over time.";
      } else if (subjectArea.toLowerCase() == "chemistry") {
        transcriptionText = "Today's lab outlines IUPAC naming protocols for alcohols and esters. Remember that the suffix changes based on functional group priority, where carboxylic acids rank highest.";
      } else if (subjectArea.toLowerCase() == "math" || subjectArea.toLowerCase() == "mathematics") {
        transcriptionText = "Exploring the derivative as the instantaneous rate of change or the slope of the tangent line. The limit definition is the limit as h approaches zero of f(x+h) minus f(x) all over h.";
      } else {
        transcriptionText = "Synthesized audio recording detailing study milestones and academic pathways. Ensure concepts are linked in mental maps for spatial learning memory.";
      }
    } else {
      transcriptionText = cleanSpeech;
    }

    final tags = ["voice-note", "ai-generated", subjectArea.toLowerCase()];
    final content = """## 🎙️ Lecture Transcript
*"$transcriptionText"*
 
---
 
## 🧠 AI Cognitive Synthesis: $subjectArea
 
### 📋 Executive Takeaways
* **Key Subject**: Focused review of $subjectArea core themes recorded by the scholar.
* **Retention Directive**: Integrate these concepts into your master study planner.
 
### 🔬 Deep Dive Analysis
* **Active Concepts**: The lecture focuses heavily on structural priorities and operational mechanics within the $subjectArea domain.
* **AI Insights**: This recorded audio notes an important focal point for upcoming exams. Consider generating a customized flashcard set to test active recall of terms mentioned.
 
*Transcribed by Aura Study Speech Core.*""";

    return StudyNote(
      id: 'voice-${now.millisecondsSinceEpoch}',
      title: "Voice Capture: $subjectArea Lecture",
      content: content,
      category: subjectArea,
      tags: tags,
      isPinned: false,
      colorHex: "0xFFFF007A", // Neon Pink
      createdAt: now,
      updatedAt: now,
    );
  }

  @override
  Future<List<QuizQuestion>> generateQuiz(String title, String content, {int count = 5}) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final lowerTitle = title.toLowerCase();
    final lowerContent = content.toLowerCase();
    
    if (lowerTitle.contains("physics") || lowerContent.contains("physics") || lowerContent.contains("quantum")) {
      return const [
        QuizQuestion(
          question: "Which of the following describes the Second Law of Thermodynamics?",
          options: [
            "Energy cannot be created or destroyed, only transformed.",
            "The entropy of an isolated system always increases over time.",
            "For every action, there is an equal and opposite reaction.",
            "As temperature approaches absolute zero, entropy approaches a constant minimum."
          ],
          correctIndex: 1,
          explanation: "The Second Law states that in any isolated thermodynamic system, total entropy or degree of disorder always tends to increase."
        ),
        QuizQuestion(
          question: "What quantum equation governs the probabilistic state transitions of wave functions over time?",
          options: [
            "Maxwell's electromagnetic equations",
            "Einstein's field equations of relativity",
            "Schrödinger's wave equation",
            "Newton's third operational law"
          ],
          correctIndex: 2,
          explanation: "Schrödinger's equation describes the evolution of wave functions governing quantum mechanical states."
        ),
        QuizQuestion(
          question: "What physical concept states that subatomic items have both particle-like and wave-like characteristics?",
          options: [
            "Quantum Superposition",
            "Wave-Particle Duality",
            "Pauli Exclusion Principle",
            "Photoelectric Resonance"
          ],
          correctIndex: 1,
          explanation: "Wave-particle duality asserts that elementary entities, such as photons and electrons, exhibit properties of both waves and particles."
        ),
        QuizQuestion(
          question: "What principle states that two identical fermions cannot occupy the same quantum state simultaneously?",
          options: [
            "Pauli Exclusion Principle",
            "Heisenberg Uncertainty Principle",
            "Planck Radiation Rule",
            "Rutherford Resonance Law"
          ],
          correctIndex: 0,
          explanation: "The Pauli Exclusion Principle states that no two identical fermions (like electrons) can occupy the same quantum state at the same time."
        ),
        QuizQuestion(
          question: "According to the Heisenberg Uncertainty Principle, which two variables cannot be simultaneously measured with absolute precision?",
          options: [
            "Mass and velocity",
            "Time and space orientation",
            "Position and momentum",
            "Charge and atomic radius"
          ],
          correctIndex: 2,
          explanation: "The Uncertainty Principle dictates that the product of uncertainties of position and momentum is bounded by Planck's constant."
        )
      ];
    } else if (lowerTitle.contains("chem") || lowerContent.contains("chem") || lowerContent.contains("organic")) {
      return const [
        QuizQuestion(
          question: "What condition holds true for a chemical reaction system to be spontaneous under standard conditions?",
          options: [
            "Gibbs Free Energy is positive (ΔG > 0)",
            "System entropy decreases to zero",
            "Gibbs Free Energy is negative (ΔG < 0)",
            "Enthalpy change must always be zero"
          ],
          correctIndex: 2,
          explanation: "A negative Gibbs Free Energy change (ΔG < 0) represents an exergonic and spontaneous reaction under standard constraints."
        ),
        QuizQuestion(
          question: "What is the IUPAC prefix designating a carbon chain consisting of exactly two carbon atoms?",
          options: [
            "Meth-",
            "Eth-",
            "Prop-",
            "But-"
          ],
          correctIndex: 1,
          explanation: "The prefix 'Eth-' stands for 2 carbons (e.g., ethane, ethanol), whereas 'Meth-' stands for 1, and 'Prop-' stands for 3."
        ),
        QuizQuestion(
          question: "Which of the following organic functional groups contains a oxygen atom double-bonded to carbon, plus a single-bonded hydroxyl group?",
          options: [
            "Aldehyde",
            "Carboxylic Acid",
            "Ketone",
            "Ester"
          ],
          correctIndex: 1,
          explanation: "Carboxylic acids (-COOH) contain both a carbonyl (C=O) and a hydroxyl (-OH) group on the same carbon atom."
        ),
        QuizQuestion(
          question: "What type of chemical bond involves the mutual sharing of electron pairs between two nonmetal atoms?",
          options: [
            "Ionic Bond",
            "Hydrogen Bond",
            "Covalent Bond",
            "Metallic Bond"
          ],
          correctIndex: 2,
          explanation: "Covalent bonding involves the stable sharing of electrons between atoms to achieve noble gas configuration."
        ),
        QuizQuestion(
          question: "Which substance increases the rate of a chemical reaction without undergoing permanent chemical change itself?",
          options: [
            "Reactant",
            "Inhibitor",
            "Catalyst",
            "Solvent"
          ],
          correctIndex: 2,
          explanation: "Catalysts provide an alternative pathway with a lower activation energy, speeding up the reaction rate without being consumed."
        )
      ];
    } else if (lowerTitle.contains("math") || lowerContent.contains("math") || lowerContent.contains("calculus")) {
      return const [
        QuizQuestion(
          question: "What eigenvalue equation represents a matrix transformation of a non-zero eigenvector x by scalar factor λ?",
          options: [
            "A + x = λx",
            "Ax = λx",
            "A^T x = x",
            "det(A) = λ"
          ],
          correctIndex: 1,
          explanation: "Ax = λx is the fundamental eigenvalue definition, where A is a square matrix, x is the eigenvector, and λ is the eigenvalue."
        ),
        QuizQuestion(
          question: "What mathematical limit represents the instantaneous rate of change of a function f(x)?",
          options: [
            "The integral of f(x)",
            "The derivative f'(x)",
            "The standard deviation of f(x)",
            "The linear slope intercept"
          ],
          correctIndex: 1,
          explanation: "The derivative measures the limit of the difference quotient as interval change approaches zero, giving the instantaneous rate."
        ),
        QuizQuestion(
          question: "What is the limit as x approaches 0 of sin(x) divided by x?",
          options: [
            "0",
            "Infinity",
            "1",
            "Undefined"
          ],
          correctIndex: 2,
          explanation: "Using L'Hôpital's rule or trigonometric limits, the limit as x approaches 0 of sin(x)/x is exactly 1."
        ),
        QuizQuestion(
          question: "What theorem establishes the bridge relationship connecting differentiation and integration?",
          options: [
            "Mean Value Theorem",
            "Fundamental Theorem of Calculus",
            "Taylor Expansion Theorem",
            "Euler's Totient Theorem"
          ],
          correctIndex: 1,
          explanation: "The Fundamental Theorem of Calculus links differentiation with integration, showing that they are inverse processes."
        ),
        QuizQuestion(
          question: "Which of the following defines a square matrix in linear algebra?",
          options: [
            "A matrix containing only zeros",
            "A matrix whose determinant is zero",
            "A matrix with the same number of rows and columns",
            "A matrix that has only a single row"
          ],
          correctIndex: 2,
          explanation: "A square matrix is a matrix with an equal count of rows and columns (e.g. 2x2, 3x3)."
        )
      ];
    } else {
      return const [
        QuizQuestion(
          question: "What is the primary objective of active recall in learning cognitive principles?",
          options: [
            "Passively reading material multiple times until memorized",
            "Testing memory retrieval to strengthen neural pathways",
            "Highlighting text in multiple neon colors",
            "Listening to lectures in the background while sleeping"
          ],
          correctIndex: 1,
          explanation: "Active recall forces the brain to retrieve information, which significantly reinforces long-term retention compared to passive reading."
        ),
        QuizQuestion(
          question: "What cognitive rule suggests focusing 80% of self-testing effort on 20% high-yield concepts?",
          options: [
            "Ebbinghaus Spacing Rule",
            "The 80/20 Pareto Rule of Retention",
            "Feynman Theoretical Rule",
            "Leitner Flashcard Hierarchy"
          ],
          correctIndex: 1,
          explanation: "The 80/20 rule optimizes efficiency by focusing on the core, high-yield ideas that form the foundation of the subject."
        ),
        QuizQuestion(
          question: "Who developed the pioneering scientific curves modeling memory retention and forgetting?",
          options: [
            "Richard Feynman",
            "Hermann Ebbinghaus",
            "B.F. Skinner",
            "Carl Jung"
          ],
          correctIndex: 1,
          explanation: "Hermann Ebbinghaus discovered the forgetting curve and spacing effect, illustrating exponential retention loss without review."
        ),
        QuizQuestion(
          question: "What technique involves simplifying a topic and explaining it as if to a young child to identify knowledge gaps?",
          options: [
            "Feynman Technique",
            "Pomodoro Technique",
            "Leitner Box Method",
            "SQ3R Method"
          ],
          correctIndex: 0,
          explanation: "The Feynman Technique uses simple explanations to test your depth of understanding and reveal hidden gaps."
        ),
        QuizQuestion(
          question: "What learning mechanism advises reviewing material at increasing intervals over time?",
          options: [
            "Active Cramming",
            "Spaced Repetition",
            "Dual Coding",
            "Interleaving Practice"
          ],
          correctIndex: 1,
          explanation: "Spaced Repetition exploits the psychological spacing effect, prompting reviews right before you are about to forget."
        )
      ];
    }
  }

  @override
  Future<List<Flashcard>> generateFlashcards(String title, String content) async {
    await Future.delayed(const Duration(milliseconds: 1200));
    
    final lowerTitle = title.toLowerCase();
    final lowerContent = content.toLowerCase();
    final category = lowerTitle.contains("physics") || lowerContent.contains("physics")
        ? "Physics"
        : lowerTitle.contains("chem") || lowerContent.contains("chem") || lowerContent.contains("organic")
            ? "Chemistry"
            : lowerTitle.contains("math") || lowerContent.contains("math") || lowerContent.contains("calculus")
                ? "Mathematics"
                : "General";

    if (category == "Physics") {
      return [
        Flashcard(
          id: 'fc-phys-1',
          frontText: "Schrödinger Equation",
          backText: "The core quantum equation describing how wave functions of physical systems change over time. Formula: iℏ∂Ψ/∂t = ĤΨ.",
          category: "Physics"
        ),
        Flashcard(
          id: 'fc-phys-2',
          frontText: "Entropy",
          backText: "A measure of molecular disorder or randomness. In isolated thermodynamic systems, entropy always tends to increase.",
          category: "Physics"
        ),
        Flashcard(
          id: 'fc-phys-3',
          frontText: "First Law of Thermodynamics",
          backText: "Conservation of Energy: energy cannot be created or destroyed, only transformed between heat, work, and internal forms.",
          category: "Physics"
        ),
        Flashcard(
          id: 'fc-phys-4',
          frontText: "Quantum Superposition",
          backText: "The principle stating that physical systems exist in multiple states simultaneously until a measurement collapses the state.",
          category: "Physics"
        ),
        Flashcard(
          id: 'fc-phys-5',
          frontText: "Pauli Exclusion Principle",
          backText: "No two identical fermions (such as electrons) can occupy the same quantum state or position at the same time.",
          category: "Physics"
        ),
        Flashcard(
          id: 'fc-phys-6',
          frontText: "Wave-Particle Duality",
          backText: "Every subatomic particle or wave quantum displays characteristics of both continuous waves and localized particles.",
          category: "Physics"
        )
      ];
    } else if (category == "Chemistry") {
      return [
        Flashcard(
          id: 'fc-chem-1',
          frontText: "Gibbs Free Energy Spontaneity Condition",
          backText: "For a reaction to occur spontaneously under constant pressure and temperature, the change in Gibbs Free Energy must be negative (ΔG < 0).",
          category: "Chemistry"
        ),
        Flashcard(
          id: 'fc-chem-2',
          frontText: "IUPAC Nomenclature Priority",
          backText: "Rules that determine the numbering sequence of carbon atoms. Carboxylic acids rank highest in suffix priority, followed by esters and aldehydes.",
          category: "Chemistry"
        ),
        Flashcard(
          id: 'fc-chem-3',
          frontText: "Covalent Bond",
          backText: "A strong interatomic connection formed by the mutual sharing of one or more electron pairs between nonmetal atoms.",
          category: "Chemistry"
        ),
        Flashcard(
          id: 'fc-chem-4',
          frontText: "Chemical Catalyst",
          backText: "A substance that speeds up the rate of reaction by providing an alternative activation energy pathway, without being consumed.",
          category: "Chemistry"
        ),
        Flashcard(
          id: 'fc-chem-5',
          frontText: "Ionic Bonding",
          backText: "Electrostatic attractions binding oppositely charged ions together, typically formed between metallic and non-metallic elements.",
          category: "Chemistry"
        ),
        Flashcard(
          id: 'fc-chem-6',
          frontText: "Exothermic Reaction",
          backText: "A chemical reaction that releases net thermal or radiant energy to its surroundings, resulting in a temperature increase.",
          category: "Chemistry"
        )
      ];
    } else if (category == "Mathematics") {
      return [
        Flashcard(
          id: 'fc-math-1',
          frontText: "Derivative Definition",
          backText: "The limit of the difference quotient as interval change approaches zero. Measures instantaneous rate of change or tangent slope.",
          category: "Mathematics"
        ),
        Flashcard(
          id: 'fc-math-2',
          frontText: "Linear Algebra Eigenvector",
          backText: "A non-zero vector whose direction is unchanged after undergoing linear matrix transformation (Ax = λx).",
          category: "Mathematics"
        ),
        Flashcard(
          id: 'fc-math-3',
          frontText: "Integral Calculus",
          backText: "The mathematical process representing the accumulation of quantities, corresponding visually to the net area under curves.",
          category: "Mathematics"
        ),
        Flashcard(
          id: 'fc-math-4',
          frontText: "Mathematical Limit",
          backText: "The value that a function or sequence approaches as the input or index gets closer to some specified target value.",
          category: "Mathematics"
        ),
        Flashcard(
          id: 'fc-math-5',
          frontText: "Determinant of a Matrix",
          backText: "A scalar value derived from a square matrix that characterizes linear transformations and indicates if a matrix is invertible.",
          category: "Mathematics"
        ),
        Flashcard(
          id: 'fc-math-6',
          frontText: "Taylor Series Expansion",
          backText: "The representation of a differentiable function as an infinite sum of polynomial terms calculated from derivatives at a single point.",
          category: "Mathematics"
        )
      ];
    } else {
      return [
        Flashcard(
          id: 'fc-gen-1',
          frontText: "Active Recall",
          backText: "A highly efficient learning method involving testing retrieval memory instead of passively reviewing or rereading sheets.",
          category: "General"
        ),
        Flashcard(
          id: 'fc-gen-2',
          frontText: "Spaced Repetition",
          backText: "Reviewing materials at exponentially increasing time intervals (e.g. 1 day, 3 days, 7 days) to combat forgetting curves.",
          category: "General"
        ),
        Flashcard(
          id: 'fc-gen-3',
          frontText: "Feynman Technique",
          backText: "An active recall strategy: attempt to explain a complex topic in the simplest possible terms, highlighting conceptual gaps.",
          category: "General"
        ),
        Flashcard(
          id: 'fc-gen-4',
          frontText: "Pomodoro Technique",
          backText: "A focus regime using timed blocks (typically 25 minutes of deep focus followed by a 5-minute break) to maintain high attention.",
          category: "General"
        ),
        Flashcard(
          id: 'fc-gen-5',
          frontText: "Cognitive Load Theory",
          backText: "A psychological premise outlining working memory limitations, advising split tasks to prevent cognitive overload.",
          category: "General"
        ),
        Flashcard(
          id: 'fc-gen-6',
          frontText: "Mind Mapping",
          backText: "Creating spatial diagram profiles representing associated nodes and links to facilitate conceptual visualization and recall.",
          category: "General"
        )
      ];
    }
  }

  @override
  Future<List<Map<String, dynamic>>> generateStudySchedule(String title, String content) async {
    await Future.delayed(const Duration(milliseconds: 1500));
    
    final lowerTitle = title.toLowerCase();
    final lowerContent = content.toLowerCase();
    
    if (lowerTitle.contains("physics") || lowerContent.contains("physics") || lowerContent.contains("quantum")) {
      return [
        {
          "title": "Quantum Mechanics Formulas",
          "details": "Derive Schrödinger wave equations and solve boundaries.",
          "category": "Physics",
          "hoursFromNow": 2,
          "reminderEnabled": true
        },
        {
          "title": "Quantum Spin Review",
          "details": "Analyze fermions spin orientation and Pauli exclusions.",
          "category": "Physics",
          "hoursFromNow": 24,
          "reminderEnabled": true
        },
        {
          "title": "Physics Active Recall",
          "details": "Self-test using newly synergized Quantum Physics flashcard deck.",
          "category": "Physics",
          "hoursFromNow": 48,
          "reminderEnabled": false
        }
      ];
    } else if (lowerTitle.contains("chemistry") || lowerContent.contains("chemistry") || lowerContent.contains("organic")) {
      return [
        {
          "title": "IUPAC Priority Hierarchy",
          "details": "Study functional groups rules and rank prefixes.",
          "category": "Chemistry",
          "hoursFromNow": 3,
          "reminderEnabled": true
        },
        {
          "title": "Biochemistry Quiz Review",
          "details": "Complete mock quiz targeting organic nomenclature rules.",
          "category": "Chemistry",
          "hoursFromNow": 26,
          "reminderEnabled": true
        }
      ];
    } else if (lowerTitle.contains("math") || lowerContent.contains("math") || lowerContent.contains("calculus") || lowerContent.contains("linear")) {
      return [
        {
          "title": "Eigenvalues Derivation",
          "details": "Formulate matrix configurations and calculate scalar values.",
          "category": "Mathematics",
          "hoursFromNow": 1,
          "reminderEnabled": true
        },
        {
          "title": "Integral Limits Calculations",
          "details": "Determine curves accumulated areas using integration boundaries.",
          "category": "Mathematics",
          "hoursFromNow": 20,
          "reminderEnabled": true
        }
      ];
    } else {
      return [
        {
          "title": "Feynman Study Integration",
          "details": "Try explaining active note core concepts in simplest words.",
          "category": "General",
          "hoursFromNow": 4,
          "reminderEnabled": true
        },
        {
          "title": "Spaced Repetition Review",
          "details": "Re-run all tagged hard flashcards inside the hub.",
          "category": "General",
          "hoursFromNow": 30,
          "reminderEnabled": false
        }
      ];
    }
  }
}

